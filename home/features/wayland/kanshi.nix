{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.wayland.kanshi;

  move-workspaces = pkgs.writeShellScript "move-workspaces" ''
    export PATH="${lib.makeBinPath [pkgs.hyprland]}"
    for pair in $@; do
      WS="''${pair%%:*}"
      MON="''${pair##*:}"
      hyprctl dispatch moveworkspacetomonitor "$WS" "$MON"
    done
  '';
in {
  options.my.wayland.kanshi = {
    enable = lib.mkEnableOption "Kanshi automatic monitor profile switching";

    profiles = lib.mkOption {
      type = lib.types.unspecified;
      default = {};
      description = "Kanshi profile definitions passed to services.kanshi.profiles";
    };
  };

  config = lib.mkIf (config.my.wayland.enable && cfg.enable) {
    home.packages = [
      (pkgs.writeShellScriptBin "move-workspaces" ''
        exec ${move-workspaces} "$@"
      '')
    ];

    services.kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
      profiles = cfg.profiles;
    };
  };
}
