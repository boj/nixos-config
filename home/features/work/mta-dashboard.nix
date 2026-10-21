# Nightly data refresh for the MTA Software Engineering Impact dashboard
# (github.com/mta-solutions/software-impact-dashboard).
#
# Runs the repo's fetch.sh + analyze.mjs as a user service, so it uses bojo's
# gh login (~/.config/gh/hosts.yml) and SSH key for GitHub. The regenerated
# data.js is picked up immediately by `tailscale serve` (which serves repoDir)
# and, when `publish` is on, committed and pushed for the GitHub Pages copy.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.work.mtaDashboard;

  refreshScript = pkgs.writeShellScript "mta-dashboard-refresh" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath (with pkgs; [
      bash
      coreutils
      findutils
      gawk
      gh
      git
      gnugrep
      gnused
      jq
      nodejs_24
      openssh
    ])}"
    export DATA_DIR=${lib.escapeShellArg cfg.dataDir}
    export GH_PROMPT_DISABLED=1 GIT_TERMINAL_PROMPT=0
    cd ${lib.escapeShellArg cfg.repoDir}

    # Pick up dashboard changes first, unless there is local work in progress.
    if [ -z "$(git status --porcelain)" ]; then
      git pull --ff-only -q || echo "mta-dashboard: git pull failed; refreshing with local code" >&2
    fi

    # fetch.sh retries individual API calls; retry the whole fetch too in case
    # GitHub has a longer outage.
    ok=
    for attempt in 1 2 3; do
      if bash ./fetch.sh; then ok=1; break; fi
      echo "mta-dashboard: fetch attempt $attempt failed" >&2
      sleep $((attempt * 300))
    done
    [ -n "$ok" ] || { echo "mta-dashboard: fetch failed; keeping previous data" >&2; exit 1; }

    node analyze.mjs > "$DATA_DIR/analyze.log"
    echo "mta-dashboard: data.js regenerated"

    ${lib.optionalString cfg.publish ''
      if ! git diff --quiet -- data.js; then
        git commit -q -m "Nightly data refresh $(date +%F)" -- data.js
        git push -q
        gh api -X POST repos/mta-solutions/software-impact-dashboard/pages/builds > /dev/null || true
        echo "mta-dashboard: published to GitHub Pages"
      fi
    ''}
  '';
in {
  options.my.work.mtaDashboard = {
    enable = lib.mkEnableOption "nightly refresh of the MTA software impact dashboard";

    repoDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/mta-dashboard";
      description = "Checkout of mta-solutions/software-impact-dashboard (also the directory tailscale serves).";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.cacheHome}/mta-dashboard";
      description = "Cache of bare clones, PRs, reviews and Copilot reports (~1 GB). Kept between runs so fetches are incremental.";
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 02:00:00";
      description = "systemd OnCalendar expression. Missed runs (laptop asleep/off) run at next wake.";
    };

    publish = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Commit and push the regenerated data.js so the GitHub Pages copy stays current.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.mta-dashboard-refresh = {
      Unit = {
        Description = "Refresh MTA software impact dashboard data";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${refreshScript}";
        Nice = 10;
        IOSchedulingClass = "idle";
        TimeoutStartSec = "3h";
      };
    };

    systemd.user.timers.mta-dashboard-refresh = {
      Unit.Description = "Nightly MTA software impact dashboard refresh";
      Timer = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
