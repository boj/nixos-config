{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.my.enshrouded;

  composeFile = pkgs.writeText "enshrouded-compose.yaml" ''
    services:
      enshrouded:
        image: sknnr/enshrouded-dedicated-server:latest
        ports:
          - "${toString cfg.port}:${toString cfg.port}/udp"
        environment:
          - SERVER_NAME=${cfg.serverName}
          - SERVER_PASSWORD=${cfg.serverPassword}
          - PORT=${toString cfg.port}
          - SERVER_SLOTS=${toString cfg.serverSlots}
          - SERVER_IP=0.0.0.0
        volumes:
          - enshrouded-data:/home/steam/enshrouded/savegame

    volumes:
      enshrouded-data:
  '';

  homeDir = config.users.users.${cfg.user}.home;
  backupDir = "${homeDir}/Backup/Enshrouded";
  containerName = "${cfg.projectName}-enshrouded-1";

  # Wrapper that ensures DOCKER_HOST points at the user's rootless docker
  # socket regardless of how the systemd user unit was started.
  withDocker = name: body:
    pkgs.writeShellScript name ''
      set -euo pipefail
      export PATH="${lib.makeBinPath [pkgs.docker pkgs.docker-compose pkgs.coreutils]}:$PATH"
      export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
      ${body}
    '';

  upScript = withDocker "enshrouded-up" ''
    mkdir -p ${backupDir}
    exec docker compose -f ${composeFile} -p ${cfg.projectName} up -d --remove-orphans
  '';

  downScript = withDocker "enshrouded-down" ''
    exec docker compose -f ${composeFile} -p ${cfg.projectName} stop
  '';

  backupScript = withDocker "enshrouded-backup" ''
    mkdir -p ${backupDir}
    exec docker cp ${containerName}:/home/steam/enshrouded/savegame/ ${backupDir}/
  '';

  restartScript = withDocker "enshrouded-restart" ''
    exec docker restart ${containerName}
  '';
in {
  options.my.enshrouded = {
    enable = lib.mkEnableOption "Enshrouded dedicated server (rootless docker, user systemd units)";

    user = lib.mkOption {
      type = lib.types.str;
      default = username;
      description = "User that owns the rootless docker daemon running the server.";
    };

    projectName = lib.mkOption {
      type = lib.types.str;
      default = "bojo";
      description = ''
        Docker Compose project name. Combined with the service name it
        determines the container name (e.g. `bojo-enshrouded-1`).
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 15637;
      description = "UDP port the Enshrouded server listens on.";
    };

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "bojo no Enshrouded";
    };

    serverPassword = lib.mkOption {
      type = lib.types.str;
      default = "bruh";
    };

    serverSlots = lib.mkOption {
      type = lib.types.int;
      default = 16;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [cfg.port];

    # Required so the user systemd manager (and rootless docker) start at
    # boot rather than waiting for an interactive login.
    users.users.${cfg.user}.linger = true;

    systemd.user.services.enshrouded = {
      description = "Enshrouded dedicated server (docker compose)";
      after = ["default.target"];
      wantedBy = ["default.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${upScript}";
        ExecStop = "${downScript}";
      };
    };

    systemd.user.services.enshrouded-backup = {
      description = "Back up Enshrouded savegame to ${backupDir}";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${backupScript}";
      };
    };

    systemd.user.timers.enshrouded-backup = {
      description = "Nightly Enshrouded savegame backup";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
        Unit = "enshrouded-backup.service";
      };
    };

    systemd.user.services.enshrouded-restart = {
      description = "Restart the Enshrouded server container";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${restartScript}";
      };
    };

    systemd.user.timers.enshrouded-restart = {
      description = "Nightly Enshrouded server restart at 04:00";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
        Unit = "enshrouded-restart.service";
      };
    };
  };
}
