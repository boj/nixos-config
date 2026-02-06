{ config, lib, pkgs, ... }:
let cfg = config.my.xdg; in {
  options.my.xdg.enable = lib.mkEnableOption "XDG portals";
  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        kdePackages.xdg-desktop-portal-kde
      ];
      wlr.enable = true;
    };
  };
}
