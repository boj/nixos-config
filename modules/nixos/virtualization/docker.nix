{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.my.virtualization.docker;
in {
  options.my.virtualization.docker.enable = lib.mkEnableOption "Docker";
  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      daemon.settings = {
        default-ulimits = {
          memlock = { Name = "memlock"; Soft = -1; Hard = -1; };
        };
      };
    };
    environment.systemPackages = with pkgs; [
      docker-compose
    ];
    users.extraGroups.docker.members = [username];
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "*";
        type = "hard";
        item = "memlock";
        value = "unlimited";
      }
    ];
  };
}
