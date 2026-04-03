{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  caelestia-cli = inputs.caelestia-shell.inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;

  fetch-wallpaper = pkgs.writeShellScript "fetch-wallpaper" ''
    export PATH="${lib.makeBinPath (with pkgs; [curl coreutils jq imagemagick]) }:${caelestia-cli}/bin"
    DIR="$HOME/Pictures/Wallpapers"
    mkdir -p "$DIR"
    TMP="$DIR/.unsplash-tmp.jpg"

    # Pick a random nature search term
    TERMS=("forest" "mountains" "ocean" "waterfall" "aurora" "canyon" "lake" "wilderness" "glacier" "rainforest" "meadow" "volcano" "desert+landscape" "autumn+forest" "tropical+island")
    QUERY=''${TERMS[$((RANDOM % ''${#TERMS[@]}))]}

    # Fetch a random nature photo via Unsplash
    URL=$(curl -fsSL "https://unsplash.com/napi/photos/random?query=$QUERY,nature,landscape&orientation=landscape&count=1" \
      | jq -r '.[0].urls.raw')
    [ -n "$URL" ] && [ "$URL" != "null" ] || exit 1

    if curl -fsSL -L -o "$TMP" "''${URL}&w=3840&q=85"; then
      IMG="$DIR/unsplash-$(date +%s).jpg"
      mv "$TMP" "$IMG" \
        && caelestia wallpaper -f "$IMG" \
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
