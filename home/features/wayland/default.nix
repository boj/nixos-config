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
    ./kanshi.nix
    ./wofi.nix
    ./wallpaper.nix
    ./wallpaper-picker
    ./gtk.nix
    ./qt.nix
    ./hyprland
  ];

  options.my.wayland.enable = lib.mkEnableOption "Wayland desktop environment";

  config = lib.mkIf cfg.enable {
    stylix.targets.hyprland.enable = false;
    stylix.targets.hyprlock.enable = false;
    stylix.targets.wofi.enable = false;
    stylix.targets.gtk.enable = false;
    stylix.targets.gnome.enable = false;
    stylix.targets.fontconfig.enable = false;
    stylix.targets.btop.enable = false;

    home.packages = with pkgs; [
      grim
      libnotify
      mpvpaper
      satty
      slurp
      swayidle
      wl-clipboard
      wofi
      ydotool
    ];

    programs.caelestia = {
      enable = true;
      cli.enable = true;
    };

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
