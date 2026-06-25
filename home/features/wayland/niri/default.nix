{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.wayland.niri;
in {
  imports = [
    ./settings.nix
    ./binds.nix
  ];

  options.my.wayland.niri = {
    enable = lib.mkEnableOption "Niri scrollable-tiling compositor";

    outputs = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      description = ''
        Niri outputs (monitors). Keys are connector names (e.g. "DP-1") or
        make/model/serial descriptors (e.g. "Dell Inc. DELL P2417H KH0NG77E1VVB").
        If left empty this is derived from `my.wayland.hyprland.monitors`.
      '';
    };

    workspaces = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      description = ''
        Niri named workspaces. Keys are workspace names. Each value may set
        `open-on-output`. If left empty this is derived from
        `my.wayland.hyprland.workspaces`.
      '';
    };

    execOnce = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Extra niri spawn-at-startup commands appended to the defaults
        (waybar, dunst, awww-daemon, hypridle if configured). By default
        these include `my.wayland.hyprland.execOnce` so both compositors
        get the same per-host autostarts. Each entry is a shell command.
      '';
    };

    useFunctionKeys = lib.mkOption {
      type = lib.types.bool;
      default = config.my.wayland.hyprland.useFunctionKeys or false;
      description = "Use function keys (F1-F9) instead of number keys for workspace switching.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      brightnessctl
      playerctl
      grim
      slurp
      wl-clipboard
      satty
      inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast
    ];

    programs.niri.package = pkgs.niri-unstable;

    # Stylix would otherwise generate its own niri config; we drive colors via
    # matugen instead (same as the hyprland setup).
    stylix.targets.niri.enable = lib.mkDefault false;
  };
}
