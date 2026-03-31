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

    # Pick a random search term for variety
    TERMS=("nebula" "galaxy" "hubble" "james+webb+space" "supernova" "star+cluster" "cosmic" "andromeda" "milky+way" "deep+field")
    QUERY=''${TERMS[$((RANDOM % ''${#TERMS[@]}))]}

    # Search NASA Image Library
    TOTAL=$(curl -fsSL "https://images-api.nasa.gov/search?q=$QUERY&media_type=image&page_size=1" \
      | jq '.collection.metadata.total_hits')
    [ "$TOTAL" -gt 0 ] 2>/dev/null || exit 1

    # Pick a random page (100 per page)
    PAGES=$(( (TOTAL + 99) / 100 ))
    [ "$PAGES" -gt 20 ] && PAGES=20
    PAGE=$((RANDOM % PAGES + 1))
    ITEMS=$(curl -fsSL "https://images-api.nasa.gov/search?q=$QUERY&media_type=image&page=$PAGE&page_size=100")

    # Pick a random item and get its NASA ID
    COUNT=$(echo "$ITEMS" | jq '.collection.items | length')
    [ "$COUNT" -gt 0 ] 2>/dev/null || exit 1
    IDX=$((RANDOM % COUNT))
    NASA_ID=$(echo "$ITEMS" | jq -r ".collection.items[$IDX].data[0].nasa_id")
    [ -n "$NASA_ID" ] && [ "$NASA_ID" != "null" ] || exit 1

    # Fetch the highest resolution image from the asset manifest
    URL=$(curl -fsSL "https://images-api.nasa.gov/asset/$NASA_ID" \
      | jq -r '.collection.items | map(select(.href | test("orig|large";"i"))) | first | .href // empty')
    [ -n "$URL" ] || URL=$(curl -fsSL "https://images-api.nasa.gov/asset/$NASA_ID" \
      | jq -r '.collection.items | map(select(.href | test("\\.(jpg|jpeg|png)$";"i"))) | last | .href // empty')
    [ -n "$URL" ] || exit 1

    if curl -fsSL -o "$TMP" "$URL"; then
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
      Unit.Description = "Fetch random NASA galaxy/nebula wallpaper";
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
