{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.my.skwd-wall;

  skwd-wall-toggle = pkgs.writeShellScriptBin "skwd-wall-toggle" ''
    export PATH="${lib.makeBinPath (with pkgs; [coreutils jq hyprland niri])}:$PATH"

    CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/skwd-wall"
    CONFIG_FILE="$CONFIG_DIR/config.json"
    mkdir -p "$CONFIG_DIR"

    monitor=""
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && command -v hyprctl >/dev/null; then
        monitor=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.monitor // ""')
    elif command -v niri >/dev/null; then
        monitor=$(niri msg -j focused-output 2>/dev/null | jq -r '.name // ""')
    fi

    if [ -n "$monitor" ]; then
        if [ -s "$CONFIG_FILE" ]; then
            tmp=$(mktemp)
            jq --arg m "$monitor" '.monitor = $m' "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
        else
            printf '{"monitor": "%s"}\n' "$monitor" > "$CONFIG_FILE"
        fi
    fi

    exec skwd wall toggle
  '';
in {
  imports = [inputs.skwd-wall.nixosModules.default];

  options.my.skwd-wall.enable =
    lib.mkEnableOption "skwd-wall wallpaper selector (with skwd-daemon)";

  config = lib.mkIf cfg.enable {
    programs.skwd-wall.enable = true;

    environment.systemPackages = [skwd-wall-toggle];

    systemd.user.services.skwd-daemon = {
      wantedBy = ["graphical-session.target"];
    };
  };
}
