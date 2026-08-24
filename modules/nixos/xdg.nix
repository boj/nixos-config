{ config, lib, pkgs, ... }:
let cfg = config.my.xdg; in {
  options.my.xdg.enable = lib.mkEnableOption "XDG portals";
  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
        kdePackages.xdg-desktop-portal-kde
      ];
      wlr.enable = true;
      # Without an explicit config, xdg-desktop-portal cannot pick a
      # FileChooser backend under XDG_CURRENT_DESKTOP=Hyprland (three are
      # installed), so Chromium/GTK file-upload dialogs silently fail to
      # open. Pin interactive dialogs to the GTK backend.
      config = {
        common.default = [ "gtk" ];
        hyprland = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
        };
      };
    };
  };
}
