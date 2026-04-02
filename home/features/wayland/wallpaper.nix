{
  config,
  lib,
  pkgs,
  ...
}: let
  fetch-wallpaper = pkgs.writeShellScript "fetch-wallpaper" ''
    export PATH="${lib.makeBinPath (with pkgs; [curl coreutils jq swww matugen hyprland procps waybar imagemagick])}"
    IMG="$HOME/.cache/wallpaper.jpg"
    TMP="$HOME/.cache/wallpaper-tmp.jpg"

    # Wait for swww-daemon to be ready
    for i in $(seq 1 30); do
      swww query >/dev/null 2>&1 && break
      sleep 1
    done

    # Pick a random nature search term (no humans)
    TERMS=("forest" "mountains" "ocean" "waterfall" "aurora" "canyon" "lake" "wilderness" "glacier" "rainforest" "meadow" "volcano" "desert+landscape" "autumn+forest" "tropical+island")
    QUERY=''${TERMS[$((RANDOM % ''${#TERMS[@]}))]}

    # Fetch a random nature photo via Unsplash internal API (no key needed)
    URL=$(curl -fsSL "https://unsplash.com/napi/photos/random?query=$QUERY,nature,landscape&orientation=landscape&count=1" \
      | jq -r '.[0].urls.raw')
    [ -n "$URL" ] && [ "$URL" != "null" ] || exit 1

    if curl -fsSL -L -o "$TMP" "''${URL}&w=3840&q=85"; then
      mv "$TMP" "$IMG" \
        && swww img "$IMG" --transition-type fade --transition-duration 2 \
        && matugen image "$IMG" --source-color-index 0 --continue-on-error -c "$HOME/.config/matugen/config.toml" 2>/dev/null \
        && mv "$HOME/.cache/matugen-waybar.css" "$HOME/.config/waybar/style.css" \
        && hyprctl keyword source "$HOME/.config/hypr/matugen-colors.conf" 2>/dev/null \
        || rm -f "$TMP"
    fi
  '';
in {
  config = lib.mkIf config.my.wayland.enable {
    systemd.user.services.fetch-wallpaper = {
      Unit.Description = "Fetch random nature wallpaper";
      Service = {
        Type = "oneshot";
        ExecStart = "${fetch-wallpaper}";
      };
    };

    systemd.user.timers.fetch-wallpaper = {
      Unit.Description = "Periodically rotate desktop wallpaper";
      Timer = {
        OnCalendar = "*:0/5";
        OnStartupSec = "15s";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
