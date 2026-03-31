{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.wayland.kanshi;

  waybar-set-workspaces = pkgs.writeShellScript "waybar-set-workspaces" ''
    export PATH="${lib.makeBinPath (with pkgs; [coreutils jq procps findutils])}"
    WORKSPACES="$1"
    CONFIG="$HOME/.config/waybar/config.jsonc"
    [ ! -e "$CONFIG" ] && CONFIG="$HOME/.config/waybar/config"
    [ ! -e "$CONFIG" ] && exit 1

    cat "$CONFIG" \
      | jq --argjson ws "$WORKSPACES" '.mainBar."hyprland/workspaces"."persistent-workspaces" = $ws' \
      > /tmp/waybar-config.tmp \
      && rm -f "$CONFIG" \
      && mv /tmp/waybar-config.tmp "$CONFIG" \
      && pkill -SIGUSR2 waybar || true
  '';

  move-workspaces = pkgs.writeShellScript "move-workspaces" ''
    export PATH="${lib.makeBinPath [pkgs.hyprland]}"
    # Usage: move-workspaces "WS:MONITOR WS:MONITOR ..."
    for pair in $@; do
      WS="''${pair%%:*}"
      MON="''${pair##*:}"
      hyprctl dispatch moveworkspacetomonitor "$WS" "$MON"
    done
  '';

  restart-waybar = pkgs.writeShellScript "restart-waybar" ''
    export PATH="${lib.makeBinPath (with pkgs; [procps waybar coreutils])}"
    pkill waybar || true
    sleep 1
    waybar &
    disown
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
      (pkgs.writeShellScriptBin "waybar-set-workspaces" ''
        exec ${waybar-set-workspaces} "$@"
      '')
      (pkgs.writeShellScriptBin "move-workspaces" ''
        exec ${move-workspaces} "$@"
      '')
      (pkgs.writeShellScriptBin "restart-waybar" ''
        exec ${restart-waybar} "$@"
      '')
    ];

    services.kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
      profiles = cfg.profiles;
    };
  };
}
