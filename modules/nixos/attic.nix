{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.my.attic;
in {
  options.my.attic = {
    server = {
      enable = lib.mkEnableOption "Attic binary cache server";
      listen = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0:8080";
        description = "Address:port for atticd to listen on. Bind to 0.0.0.0 so Tailscale peers can reach it.";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open the atticd port on the Tailscale interface only.";
      };
      credentialsFile = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/atticd/env";
        description = ''
          EnvironmentFile for atticd. Must define ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64.
          Generate once with:
            openssl rand 64 | base64 -w0
          Then write:
            ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64=<value>
        '';
      };
    };

    client = {
      enable = lib.mkEnableOption "Attic client (adds attic-client to PATH and configures nix substituter)";
      cacheUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://bruh:8080/system";
        description = "Public URL of the attic cache to pull from. Uses Tailscale MagicDNS.";
      };
      publicKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "system:abc123...=";
        description = ''
          Public signing key for the cache. Get it after creating the cache:
            atticadm --config /etc/atticd/config.toml gen-key system
          Or via CLI once logged in:
            attic cache info system
          Leave null until you've bootstrapped the server.
        '';
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.server.enable {
      services.atticd = {
        enable = true;
        package = inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic-server;
        environmentFile = cfg.server.credentialsFile;
        settings = {
          listen = cfg.server.listen;
          # Local filesystem storage. Swap for S3/GCS later if desired.
          storage = {
            type = "local";
            path = "/var/lib/atticd/storage";
          };
          # Reasonable defaults for a single-user setup.
          chunking = {
            nar-size-threshold = 65536; # 64 KiB — chunk anything larger
            min-size = 16384;           # 16 KiB
            avg-size = 65536;           # 64 KiB
            max-size = 262144;          # 256 KiB
          };
          # Garbage collection every day at 03:00.
          garbage-collection = {
            interval = "1 day";
          };
        };
      };

      # Ensure the state dir exists with correct perms (systemd handles most of this,
      # but the env file is user-managed).
      systemd.tmpfiles.rules = [
        "d /var/lib/atticd 0750 atticd atticd -"
        "d /var/lib/atticd/storage 0750 atticd atticd -"
      ];

      # Open the port on the Tailscale interface only — never on the public LAN.
      networking.firewall.interfaces."tailscale0".allowedTCPPorts =
        lib.mkIf cfg.server.openFirewall [8080];
    })

    (lib.mkIf cfg.client.enable {
      environment.systemPackages = [
        inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic-client
      ];

      # Wire the cache into nix as a substituter. Only takes effect once
      # publicKey is set (nix refuses unsigned substituters).
      nix.settings = lib.mkIf (cfg.client.publicKey != null) {
        substituters = [cfg.client.cacheUrl];
        trusted-substituters = [cfg.client.cacheUrl];
        trusted-public-keys = [cfg.client.publicKey];
      };
    })
  ];
}
