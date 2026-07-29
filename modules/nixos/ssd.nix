{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.ssd;

  # Weekly short self-test on every NVMe namespace present at run time.
  # Uses `nvme device-self-test` (short = 1) which is non-destructive and
  # runs in the background on the controller.
  nvmeSelfTest = pkgs.writeShellApplication {
    name = "nvme-self-test";
    runtimeInputs = [pkgs.nvme-cli pkgs.util-linux pkgs.coreutils];
    text = ''
      set -euo pipefail
      shopt -s nullglob
      found=0
      for dev in /dev/nvme*n*; do
        # Skip partitions (e.g. nvme0n1p1), keep namespaces (nvme0n1).
        case "$dev" in
          *p[0-9]*) continue ;;
        esac
        found=1
        echo "Starting NVMe short self-test on $dev"
        nvme device-self-test "$dev" -s 1 || {
          echo "Failed to start self-test on $dev" >&2
          continue
        }
      done
      if [ "$found" -eq 0 ]; then
        echo "No NVMe namespaces found; nothing to test."
      fi
    '';
  };

  # Health snapshot script — writes SMART + NVMe health log to the journal.
  nvmeHealthReport = pkgs.writeShellApplication {
    name = "nvme-health-report";
    runtimeInputs = [pkgs.nvme-cli pkgs.smartmontools pkgs.coreutils];
    text = ''
      set -uo pipefail
      shopt -s nullglob
      for dev in /dev/nvme*n*; do
        case "$dev" in
          *p[0-9]*) continue ;;
        esac
        echo "===== $dev ====="
        echo "--- nvme smart-log ---"
        nvme smart-log "$dev" || true
        echo "--- smartctl -H -A ---"
        smartctl -H -A "$dev" || true
        echo "--- nvme self-test-log ---"
        nvme self-test-log "$dev" || true
      done
    '';
  };
in {
  options.my.ssd = {
    enable = lib.mkEnableOption "SSD/NVMe integrity monitoring (smartd + periodic self-tests)";

    selfTest = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run a weekly NVMe short self-test on all namespaces.";
      };
      onCalendar = lib.mkOption {
        type = lib.types.str;
        default = "Sun 03:00";
        description = "systemd OnCalendar spec for the NVMe self-test timer.";
      };
    };

    healthReport = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Log a daily NVMe/SMART health snapshot to the journal.";
      };
      onCalendar = lib.mkOption {
        type = lib.types.str;
        default = "daily";
        description = "systemd OnCalendar spec for the health report timer.";
      };
    };

    notifyEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "root@localhost";
      description = ''
        Optional email address for smartd alerts. Requires a working MTA
        (e.g. `services.postfix` or `programs.msmtp`). If null, alerts are
        only written to syslog / the journal.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      smartmontools
      nvme-cli
      nvmeSelfTest
      nvmeHealthReport
    ];

    # Weekly TRIM. On NVMe/SSD this tells the controller which LBAs are
    # free, keeping garbage collection efficient and write latency low
    # as the drive fills up.
    services.fstrim = {
      enable = true;
      interval = "weekly";
    };

    # Continuous SMART monitoring. `autodetect` picks up every disk,
    # including NVMe. `-a` = all attributes, `-o on` = SMART offline
    # collection, `-S on` = attribute autosave, `-s (S/../.././02|L/../../6/03)`
    # schedules smartd-driven short/long self-tests for SATA devices.
    services.smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        wall.enable = true;
        x11.enable = false;
      }
      // lib.optionalAttrs (cfg.notifyEmail != null) {
        mail = {
          enable = true;
          sender = "smartd@${config.networking.hostName}";
          recipient = cfg.notifyEmail;
        };
      };
      defaults.autodetected = "-a -o on -S on -n standby,q -s (S/../.././02|L/../../6/03) -W 4,45,55";
    };

    systemd.services.nvme-self-test = lib.mkIf cfg.selfTest.enable {
      description = "NVMe short self-test on all namespaces";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${nvmeSelfTest}/bin/nvme-self-test";
      };
    };

    systemd.timers.nvme-self-test = lib.mkIf cfg.selfTest.enable {
      description = "Weekly NVMe short self-test";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.selfTest.onCalendar;
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
    };

    systemd.services.nvme-health-report = lib.mkIf cfg.healthReport.enable {
      description = "NVMe/SMART health snapshot to the journal";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${nvmeHealthReport}/bin/nvme-health-report";
      };
    };

    systemd.timers.nvme-health-report = lib.mkIf cfg.healthReport.enable {
      description = "Daily NVMe/SMART health snapshot";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.healthReport.onCalendar;
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
