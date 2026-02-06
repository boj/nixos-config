{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.wayland.hyprland;
in {
  imports = [
    ./binds.nix
    ./rules.nix
    ./settings.nix
  ];

  options.my.wayland.hyprland.enable = lib.mkEnableOption "Hyprland window manager";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpaper
      hyprpicker
      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    ];

    wayland.windowManager.hyprland = {
      enable = true;
    };

    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };
  };
}
