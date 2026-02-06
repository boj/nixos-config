{ config, lib, pkgs, username, ... }:
let cfg = config.my.virtualization.docker; in {
  options.my.virtualization.docker.enable = lib.mkEnableOption "Docker";
  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    environment.systemPackages = with pkgs; [
      docker-compose
    ];
    users.extraGroups.docker.members = [username];
  };
}
