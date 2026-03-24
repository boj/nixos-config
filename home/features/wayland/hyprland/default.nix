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

  options.my.wayland.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Hyprland monitor configuration strings";
      example = [ "DP-1,1920x1080@240,0x0,1" ];
    };

    workspaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Hyprland workspace configuration strings";
      example = [ "1,monitor:DP-1,default:true" ];
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpaper
      hyprpicker
      inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast
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
