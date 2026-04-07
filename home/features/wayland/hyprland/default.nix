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
    ./hypridle.nix
    ./hyprlock.nix
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

    execOnce = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Hyprland exec-once commands (per-host startup apps)";
      example = [ "[workspace 1 silent] firefox" ];
    };

    useFunctionKeys = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use function keys (F1-F9, F10) instead of number keys for workspace switching";
    };

    idleTimeout = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Idle timeout in seconds before locking screen (null to disable hypridle)";
      example = 1800;
    };

    dpmsTimeout = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Idle timeout in seconds before turning off displays (null defaults to idleTimeout + 300)";
      example = 3600;
    };

    workspaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Hyprland workspace configuration strings";
      example = [ "1,monitor:DP-1,default:true" ];
    };

    waybarPersistentWorkspaces = lib.mkOption {
      type = lib.types.attrs;
      default = {"*" = 5;};
      description = "Waybar persistent-workspaces mapping (monitor name to workspace list or count)";
      example = { "DP-1" = [1 2 3]; "DP-2" = [4 5 6]; };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hypridle
      hyprlock
      hyprpaper
      hyprpicker
      brightnessctl
      playerctl
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
