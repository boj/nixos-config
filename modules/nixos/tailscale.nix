{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.tailscale;
in {
  options.my.tailscale.enable = lib.mkEnableOption "Tailscale";
  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      #extraUpFlags = [
      #  "--ssh"
      #];
      #extraSetFlags = [
      #  "--accept-routes"
      #];
    };

    # DNS resilience. Tailscale's MagicDNS points /etc/resolv.conf at a single
    # resolver (100.100.100.100). With no fallback, a slow or unreachable
    # tailnet resolver makes every getaddrinfo() pay the full glibc timeout
    # (5s x 2 attempts, multiplied across search domains) — a ~30s stall on
    # anything that resolves a name at startup (GUI apps, network CLIs, etc.).
    #
    # systemd-resolved fixes this: tailscaled detects resolved and hands it the
    # MagicDNS server as split-DNS for the tailnet's search domains, while all
    # other lookups use fallbackDns. A flaky tailnet resolver can then never
    # freeze global name resolution. resolved also adds `resolve` to nsswitch,
    # so glibc goes through the local stub (127.0.0.53) instead of hard-wiring
    # a single upstream.
    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = false; # MagicDNS doesn't sign responses; avoid validation stalls.
        FallbackDNS = [
          "1.1.1.1"
          "1.0.0.1"
          "9.9.9.9"
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      tailscale
    ];
  };
}
