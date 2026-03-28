{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.wayland;
in {
  imports = [
    ./dunst.nix
    ./waybar.nix
    ./wofi.nix
    ./wallpaper.nix
    ./gtk.nix
    ./qt.nix
    ./ags.nix
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

    home.packages = with pkgs; [
      # wayland
      grim
      libnotify
      mpvpaper
      slurp
      swww
      swayidle
      waybar
      waypaper
      wl-clipboard
      wofi
      ydotool
    ];

    home.sessionVariables = {
      # SDL_VIDEODRIVER = "wayland";
      WLR_RENDERER = "vulkan";
      XDG_SESSION_TYPE = "wayland";
      GTK_USE_PORTAL = "1";
      NIXOS_XDG_OPEN_USE_PORTAL = "1";
    };
  };
}
