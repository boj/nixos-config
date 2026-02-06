{ config, lib, username, ... }:
let cfg = config.my.plex; in {
  options.my.plex.enable = lib.mkEnableOption "Plex";
  config = lib.mkIf cfg.enable {
    services.plex = {
      enable = true;
      openFirewall = true;
      user = username;
    };
  };
}
