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

    # Fetch a random sci-fi wallpaper from wallhaven
    URL=$(curl -fsSL "https://wallhaven.cc/api/v1/search?q=dark+nature&categories=100&purity=100&sorting=random&atleast=1920x1080" \
      | jq -r '.data[0].path')

    if [ -n "$URL" ] && [ "$URL" != "null" ]; then
      curl -fsSL -o "$TMP" "$URL" \
        && mv "$TMP" "$IMG" \
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
      Unit.Description = "Fetch random sci-fi wallpaper from Wallhaven";
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
