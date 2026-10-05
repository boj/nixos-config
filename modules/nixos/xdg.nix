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
      #
      # This block is Hyprland-specific (it emits `hyprland-portals.conf`), so
      # it only applies in a Hyprland session. Under Umbriel the
      # xdg-desktop-portal-umbriel module supplies its own
      # `umbriel-portals.conf` (umbriel;gtk), so we leave portal routing to it.
      #
      # `common.*` only lands in `portals.conf`, which xdg-desktop-portal
      # *ignores* whenever a `$XDG_CURRENT_DESKTOP-portals.conf` exists. This is
      # a Hyprland session (XDG_CURRENT_DESKTOP=Hyprland) and the Hyprland
      # package ships its own `hyprland-portals.conf` (`default=hyprland;gtk`),
      # so the common config never takes effect here. The interactive dialog
      # interfaces (FileChooser/OpenURI) therefore have no explicit backend and
      # Chromium/GTK file-upload dialogs silently fail to open.
      #
      # Emit our own `hyprland-portals.conf` (via the `hyprland` desktop key)
      # into /etc/xdg, which outranks the package copy, and pin the dialog
      # interfaces to GTK while leaving ScreenCast/Screenshot/GlobalShortcuts on
      # Hyprland's own backend.
      config = lib.mkIf config.programs.hyprland.enable {
        common.default = ["hyprland" "gtk"];
        hyprland = {
          default = ["hyprland" "gtk"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
          "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
        };
      };
    };
  };
}
