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

    # Ensure scheme is dynamic so colors are derived from the wallpaper
    caelestia scheme set -n dynamic 2>/dev/null || true

    # Fetch a random linux wallpaper from Unsplash
    URL=$(curl -fsSL "https://unsplash.com/napi/photos/random?query=linux+wallpaper&orientation=landscape&count=1" \
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
      Unit.Description = "Fetch random linux wallpaper";
      Service = {
        Type = "oneshot";
        ExecStart = "${fetch-wallpaper}";
      };
    };
  };
}
