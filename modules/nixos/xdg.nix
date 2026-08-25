{ config, lib, pkgs, ... }:
let cfg = config.my.xdg; in {
  options.my.xdg.enable = lib.mkEnableOption "XDG portals";
  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      # This is a Hyprland session. `programs.hyprland` already pulls in
      # xdg-desktop-portal-hyprland, which handles ScreenCast/Screenshot/
      # global shortcuts. We only add the GTK backend as a fallback for the
      # interfaces Hyprland's portal doesn't implement (FileChooser, Settings,
      # etc.).
      #
      # Previously this also installed the GNOME and KDE portals (and enabled
      # the wlr portal). With several backends installed and no explicit
      # `config`, xdg-desktop-portal routed interface requests to the GNOME/KDE
      # backends, which need a running GNOME/KDE session. Those D-Bus calls
      # blocked for the full 25s activation timeout on every app that queried a
      # portal at startup (GTK/Qt/Electron apps read org.freedesktop.portal
      # .Settings on launch), making applications load obnoxiously slowly.
      extraPortals = [pkgs.xdg-desktop-portal-gtk];

      # Pin the backend order explicitly so no interface can fall through to an
      # unavailable backend and stall on a D-Bus timeout.
      config.common.default = ["hyprland" "gtk"];
    };
  };
}
