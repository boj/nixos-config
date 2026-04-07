{
  config,
  lib,
  pkgs,
  inputs,
  defaultWallpaper,
  ...
}:
let
  cfg = config.my.wayland;
in {
  imports = [
    ./dunst.nix
    ./kanshi.nix
    ./waybar.nix
    ./wofi.nix
    ./wallpaper.nix
    ./wallpaper-picker
    ./gtk.nix
    ./qt.nix
    ./hyprland
  ];

  options.my.wayland.enable = lib.mkEnableOption "Wayland desktop environment";

  config = lib.mkIf cfg.enable {
    stylix.targets.waybar.enable = false;
    stylix.targets.hyprland.enable = false;
    stylix.targets.hyprlock.enable = false;
    stylix.targets.dunst.enable = false;
    stylix.targets.wofi.enable = false;
    stylix.targets.gtk.enable = false;
    stylix.targets.gnome.enable = false;
    stylix.targets.fontconfig.enable = false;
    stylix.targets.btop.enable = false;

    home.packages = with pkgs; [
      grim
      libnotify
      matugen
      mpvpaper
      satty
      slurp
      swww
      swayidle
      waybar
      waypaper
      wl-clipboard
      wofi
      ydotool
    ];

    xdg.configFile."matugen/config.toml".text = ''
      [config]
      variant = "dark"
      palette = "scheme-tonal-spot"
      contrast = 0.0

      [templates.waybar]
      input_path = "${./templates/waybar.css}"
      output_path = "~/.cache/matugen-waybar.css"

      [templates.hyprland-colors]
      input_path = "${./templates/hyprland-colors.conf}"
      output_path = "~/.config/hypr/matugen-colors.conf"

      [templates.chromium-theme]
      input_path = "${./templates/chromium-theme.json}"
      output_path = "~/.config/chromium-matugen-theme/manifest.json"
    '';

    home.activation.matugenInit = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/chromium-matugen-theme"
      touch "$HOME/.config/hypr/matugen-colors.conf"
      ${pkgs.matugen}/bin/matugen image ${defaultWallpaper} --source-color-index 0 --continue-on-error -c "$HOME/.config/matugen/config.toml" 2>/dev/null || true
      mv "$HOME/.cache/matugen-waybar.css" "$HOME/.config/waybar/style.css" 2>/dev/null || true
    '';

    home.sessionVariables = {
      # SDL_VIDEODRIVER = "wayland";
      WLR_RENDERER = "vulkan";
      XDG_SESSION_TYPE = "wayland";
      GTK_USE_PORTAL = "1";
      NIXOS_XDG_OPEN_USE_PORTAL = "1";
      NIXOS_OZONE_WL = "1";
    };
  };
}
