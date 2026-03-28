{
  config,
  lib,
  pkgs,
  ...
}: let
  lockscreen-wallpaper = "$HOME/.cache/lockscreen.png";

  fetch-lockscreen = pkgs.writeShellScript "fetch-lockscreen" ''
    export PATH="${lib.makeBinPath (with pkgs; [curl coreutils])}"
    IMG="$HOME/.cache/lockscreen.png"
    TMP="$HOME/.cache/lockscreen-tmp.jpg"
    curl -fsSL -o "$TMP" "https://picsum.photos/3840/2160" \
      && mv "$TMP" "$IMG" \
      || rm -f "$TMP"
  '';
in {
  config = lib.mkIf config.my.wayland.hyprland.enable {
    systemd.user.services.fetch-lockscreen = {
      Unit.Description = "Fetch lockscreen wallpaper from Unsplash";
      Service = {
        Type = "oneshot";
        ExecStart = "${fetch-lockscreen}";
      };
    };

    systemd.user.timers.fetch-lockscreen = {
      Unit.Description = "Periodically fetch lockscreen wallpaper";
      Timer = {
        OnCalendar = "hourly";
        OnStartupSec = "10s";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };

    xdg.configFile."hypr/hyprlock.conf".text = let
      palette = config.lib.stylix.colors;
    in ''
      general {
        hide_cursor = true
        grace = 3
      }

      background {
        monitor =
        path = ${lockscreen-wallpaper}
        color = rgb(${palette.base00})
        blur_passes = 0
      }

      input-field {
        monitor =
        size = 300, 50
        outline_thickness = 2
        dots_size = 0.25
        dots_spacing = 0.2
        dots_center = true
        outer_color = rgb(${palette.base0E})
        inner_color = rgb(${palette.base01})
        font_color = rgb(${palette.base05})
        fade_on_empty = true
        placeholder_text = <i>Password...</i>
        hide_input = false
        position = 0, -20
        halign = center
        valign = center
      }

      label {
        monitor =
        text = $TIME
        color = rgb(${palette.base05})
        font_size = 64
        font_family = sans-serif
        position = 0, 120
        halign = center
        valign = center
      }

      label {
        monitor =
        text = Hi, $USER
        color = rgb(${palette.base07})
        font_size = 20
        font_family = sans-serif
        position = 0, 60
        halign = center
        valign = center
      }
    '';
  };
}
