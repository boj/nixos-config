{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.cloudflare-ddns;

  updateScript = pkgs.writeShellScript "cloudflare-ddns-update" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath (with pkgs; [curl jq coreutils])}"

    TOKEN_FILE="${cfg.tokenFile}"
    if [ ! -r "$TOKEN_FILE" ]; then
      echo "cloudflare-ddns: token file '$TOKEN_FILE' is missing or unreadable" >&2
      exit 1
    fi
    CF_TOKEN="$(tr -d '[:space:]' < "$TOKEN_FILE")"
    if [ -z "$CF_TOKEN" ]; then
      echo "cloudflare-ddns: token file is empty" >&2
      exit 1
    fi

    ZONE="${cfg.zone}"
    RECORD="${cfg.record}"
    RECORD_TYPE="${cfg.recordType}"
    TTL="${toString cfg.ttl}"
    PROXIED=${if cfg.proxied then "true" else "false"}

    api() {
      curl -fsS \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json" \
        "$@"
    }

    IP="$(curl -fsS --retry 3 --max-time 10 https://api.ipify.org)"
    if ! echo "$IP" | grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
      echo "cloudflare-ddns: failed to determine public IP (got '$IP')" >&2
      exit 1
    fi

    ZONE_ID="$(api "https://api.cloudflare.com/client/v4/zones?name=$ZONE" \
      | jq -er '.result[0].id')"

    RECORD_JSON="$(api "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=$RECORD_TYPE&name=$RECORD")"
    RECORD_ID="$(echo "$RECORD_JSON" | jq -r '.result[0].id // empty')"
    CURRENT_IP="$(echo "$RECORD_JSON" | jq -r '.result[0].content // empty')"

    PAYLOAD="$(jq -nc \
      --arg type "$RECORD_TYPE" \
      --arg name "$RECORD" \
      --arg content "$IP" \
      --argjson ttl "$TTL" \
      --argjson proxied "$PROXIED" \
      '{type:$type, name:$name, content:$content, ttl:$ttl, proxied:$proxied}')"

    if [ -z "$RECORD_ID" ]; then
      echo "cloudflare-ddns: creating $RECORD_TYPE record $RECORD -> $IP"
      api -X POST \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        --data "$PAYLOAD" >/dev/null
    elif [ "$CURRENT_IP" = "$IP" ]; then
      echo "cloudflare-ddns: $RECORD already points to $IP, no change"
    else
      echo "cloudflare-ddns: updating $RECORD from $CURRENT_IP to $IP"
      api -X PUT \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
        --data "$PAYLOAD" >/dev/null
    fi
  '';
in {
  options.my.services.cloudflare-ddns = {
    enable = lib.mkEnableOption "Cloudflare dynamic DNS updater (user service)";

    record = lib.mkOption {
      type = lib.types.str;
      description = "Fully-qualified DNS record to keep pointed at this network's public IP.";
    };

    zone = lib.mkOption {
      type = lib.types.str;
      description = "Cloudflare zone (apex domain) that owns the record.";
    };

    recordType = lib.mkOption {
      type = lib.types.enum ["A" "AAAA"];
      default = "A";
      description = "DNS record type to manage.";
    };

    ttl = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "TTL in seconds (1 = automatic).";
    };

    proxied = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to proxy the record through Cloudflare.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/cloudflare-ddns/token";
      description = ''
        Path to a file containing a Cloudflare API token with
        Zone:Read + DNS:Edit permissions on the target zone.
      '';
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "*:0/5";
      description = "systemd OnCalendar expression for refresh frequency.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.cloudflare-ddns = {
      Unit = {
        Description = "Update ${cfg.record} on Cloudflare with current public IP";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${updateScript}";
      };
    };

    systemd.user.timers.cloudflare-ddns = {
      Unit.Description = "Periodically refresh ${cfg.record} via Cloudflare DDNS";
      Timer = {
        OnCalendar = cfg.interval;
        OnStartupSec = "30s";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
