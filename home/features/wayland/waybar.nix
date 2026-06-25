{
  config,
  lib,
  pkgs,
  ...
}: let
  batteryEnabled = config.my.wayland.battery.enable;
  weatherCfg = config.my.wayland.weather;

  # Picks the right waybar config per session. Used as the waybar autostart
  # in both compositors so each session gets its own workspaces module
  # (hyprland/workspaces vs niri/workspaces). Defined at top-level so other
  # modules (kanshi, hyprland, niri) can reference it by absolute path,
  # avoiding PATH-lookup failures when the compositor is started by greetd
  # before the user profile is on PATH.
  waybar-session = pkgs.writeShellScriptBin "waybar-session" ''
    CFG_DIR="$HOME/.config/waybar"
    STYLE="$CFG_DIR/style.css"
    case "''${XDG_CURRENT_DESKTOP,,}" in
      *niri*)     CFG="$CFG_DIR/config-niri.jsonc" ;;
      *hyprland*) CFG="$CFG_DIR/config-hyprland.jsonc" ;;
      *)          CFG="$CFG_DIR/config-hyprland.jsonc" ;;
    esac
    if [ -f "$STYLE" ]; then
      exec ${pkgs.waybar}/bin/waybar -c "$CFG" -s "$STYLE"
    else
      exec ${pkgs.waybar}/bin/waybar -c "$CFG"
    fi
  '';
in let
  weather-script = pkgs.writeShellScript "waybar-weather" ''
    export PATH="${lib.makeBinPath (with pkgs; [curl coreutils jq])}"

    CACHE="''${XDG_RUNTIME_DIR:-/tmp}/waybar-weather.json"
    MODE="''${1:-temp}"

    # Refresh cache if stale (>9 min) or missing
    if [ ! -f "$CACHE" ] || [ "$(( $(date +%s) - $(date -r "$CACHE" +%s) ))" -gt 540 ]; then
      DATA=$(curl -fsSL --max-time 10 \
        "https://api.open-meteo.com/v1/forecast?latitude=${toString weatherCfg.latitude}&longitude=${toString weatherCfg.longitude}&current=temperature_2m,weather_code,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,precipitation,cloud_cover,uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=America/Anchorage&forecast_days=3" \
        2>/dev/null) || true

      if [ -n "$DATA" ] && echo "$DATA" | jq -e '.current' >/dev/null 2>&1; then
        echo "$DATA" > "$CACHE"
      fi
    fi

    if [ ! -f "$CACHE" ]; then
      if [ "$MODE" = "icon" ]; then
        echo '{"text":"?","tooltip":"Weather unavailable","class":"error"}'
      else
        echo '{"text":"--°F","tooltip":"Weather unavailable","class":"error"}'
      fi
      exit 0
    fi

    DATA=$(cat "$CACHE")
    TEMP=$(echo "$DATA" | jq -r '.current.temperature_2m | round')
    CODE=$(echo "$DATA" | jq -r '.current.weather_code')
    FEELS_LIKE=$(echo "$DATA" | jq -r '.current.apparent_temperature | round')
    HUMIDITY=$(echo "$DATA" | jq -r '.current.relative_humidity_2m')
    WIND=$(echo "$DATA" | jq -r '.current.wind_speed_10m | round')
    GUSTS=$(echo "$DATA" | jq -r '.current.wind_gusts_10m | round')
    WIND_DIR=$(echo "$DATA" | jq -r '.current.wind_direction_10m')
    PRESSURE=$(echo "$DATA" | jq -r '.current.pressure_msl | round')
    PRECIP=$(echo "$DATA" | jq -r '.current.precipitation')
    CLOUD=$(echo "$DATA" | jq -r '.current.cloud_cover')
    UV=$(echo "$DATA" | jq -r '.current.uv_index')

    # Wind direction to compass
    DIR_NUM=$(( (WIND_DIR + 23) / 45 % 8 ))
    case "$DIR_NUM" in
      0) COMPASS="N" ;; 1) COMPASS="NE" ;; 2) COMPASS="E" ;; 3) COMPASS="SE" ;;
      4) COMPASS="S" ;; 5) COMPASS="SW" ;; 6) COMPASS="W" ;; 7) COMPASS="NW" ;;
    esac

    wmo_icon() {
      case "$1" in
        0)        echo "☀" ;;  1)        echo "🌤" ;;
        2)        echo "⛅" ;; 3)        echo "☁" ;;
        45|48)    echo "🌫" ;; 51|53|55) echo "🌧" ;;
        61|63|65) echo "🌧" ;; 66|67)    echo "🌨" ;;
        71|73|75|77) echo "❄" ;;
        80|81|82) echo "🌧" ;; 85|86)    echo "🌨" ;;
        95|96|99) echo "⛈" ;;  *)        echo "🌤" ;;
      esac
    }
    wmo_desc() {
      case "$1" in
        0) echo "Clear" ;;          1) echo "Mostly clear" ;;
        2) echo "Partly cloudy" ;;  3) echo "Overcast" ;;
        45|48) echo "Fog" ;;        51|53|55) echo "Drizzle" ;;
        61|63|65) echo "Rain" ;;    66|67) echo "Freezing rain" ;;
        71|73|75) echo "Snow" ;;    77) echo "Snow grains" ;;
        80|81|82) echo "Showers" ;; 85|86) echo "Snow showers" ;;
        95) echo "Thunderstorm" ;;  96|99) echo "T-storm + hail" ;;
        *) echo "Unknown" ;;
      esac
    }

    ICON=$(wmo_icon "$CODE")
    CONDITION=$(wmo_desc "$CODE")

    # Sunrise/sunset for today
    SUNRISE=$(echo "$DATA" | jq -r '.daily.sunrise[0]' | cut -d'T' -f2)
    SUNSET=$(echo "$DATA" | jq -r '.daily.sunset[0]' | cut -d'T' -f2)

    # Build 3-day forecast lines
    FORECAST=""
    for i in 0 1 2; do
      DAY=$(echo "$DATA" | jq -r ".daily.time[$i]")
      DAY_NAME=$(date -d "$DAY" +%a)
      D_CODE=$(echo "$DATA" | jq -r ".daily.weather_code[$i]")
      D_ICON=$(wmo_icon "$D_CODE")
      D_HI=$(echo "$DATA" | jq -r ".daily.temperature_2m_max[$i] | round")
      D_LO=$(echo "$DATA" | jq -r ".daily.temperature_2m_min[$i] | round")
      D_PRECIP=$(echo "$DATA" | jq -r ".daily.precipitation_probability_max[$i]")
      FORECAST="$FORECAST$(printf '\n%s %s %s°/%s°F  %s%% precip' "$D_ICON" "$DAY_NAME" "$D_HI" "$D_LO" "$D_PRECIP")"
    done

    TOOLTIP=$(printf "%s %s  %s°F (feels %s°F)\n\nWind: %s mph %s (gusts %s)\nHumidity: %s%%\nPressure: %s hPa\nCloud cover: %s%%\nUV index: %s\nPrecipitation: %s in\nSunrise: %s  Sunset: %s\n%s" \
      "$ICON" "$CONDITION" "$TEMP" "$FEELS_LIKE" \
      "$WIND" "$COMPASS" "$GUSTS" \
      "$HUMIDITY" "$PRESSURE" "$CLOUD" "$UV" "$PRECIP" \
      "$SUNRISE" "$SUNSET" \
      "$FORECAST")

    if [ "$MODE" = "icon" ]; then
      jq -nc --arg text "$ICON" --arg tooltip "$TOOLTIP" \
        '{"text":$text,"tooltip":$tooltip,"class":"weather"}'
    else
      jq -nc --arg text "$TEMP°F" --arg tooltip "$TOOLTIP" \
        '{"text":$text,"tooltip":$tooltip,"class":"weather"}'
    fi
  '';
  mic-script = pkgs.writeShellScript "waybar-mic" ''
    export PATH="${lib.makeBinPath (with pkgs; [wireplumber gawk gnugrep])}"
    MIC=$(printf '\uF130')
    MIC_MUTED=$(printf '\uF131')
    STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    if echo "$STATUS" | grep -q MUTED; then
      echo "{\"text\":\"$MIC_MUTED\",\"class\":\"muted\",\"tooltip\":\"Mic: Muted\"}"
    else
      VOL=$(echo "$STATUS" | awk '{printf "%.0f", $2 * 100}')
      echo "{\"text\":\"$MIC\",\"class\":\"unmuted\",\"tooltip\":\"Mic: $VOL%\"}"
    fi
  '';
in {
  options.my.wayland.battery.enable = lib.mkEnableOption "battery indicator in waybar";

  options.my.wayland.weather.latitude = lib.mkOption {
    type = lib.types.float;
    default = 61.60;
    description = "Latitude for weather widget (Open-Meteo)";
  };

  options.my.wayland.weather.longitude = lib.mkOption {
    type = lib.types.float;
    default = -149.11;
    description = "Longitude for weather widget (Open-Meteo)";
  };

  options.my.wayland.waybarSessionPackage = lib.mkOption {
    type = lib.types.package;
    readOnly = true;
    default = waybar-session;
    description = ''
      Package providing the `waybar-session` wrapper that selects the
      correct waybar config for the running compositor. Exposed so that
      other modules can reference its absolute path (via `lib.getExe`)
      instead of relying on PATH lookup.
    '';
  };

  config = lib.mkIf config.my.wayland.enable (let
    workspaceIcons = {
      "1" = "1"; "2" = "2"; "3" = "3"; "4" = "4"; "5" = "5";
      "6" = "6"; "7" = "7"; "8" = "8"; "9" = "9"; "10" = "0";
    };

    hyprlandWorkspaces = {
      on-click = "activate";
      format = "{icon}";
      format-icons = workspaceIcons;
      persistent-workspaces = config.my.wayland.hyprland.waybarPersistentWorkspaces;
    };

    # niri/workspaces uses workspace names; we configured named workspaces
    # "1".."9" in niri/settings.nix so the same icon map applies.
    niriWorkspaces = {
      on-click = "activate";
      format = "{icon}";
      format-icons = workspaceIcons;
      all-outputs = false;
    };

    mkBar = workspacesModule: {
      layer = "top";
      position = "left";
      margin-top = 8;
      margin-bottom = 8;
      margin-left = 8;
      reload_style_on_change = true;
      modules-left = ["custom/weather-temp" "custom/weather-icon"];
      modules-center = [workspacesModule.name "clock#date" "clock#time"];
      modules-right = ["tray" "pulseaudio/slider" "pulseaudio#percentage" "custom/mic" "network" "network#percentage"]
        ++ lib.optionals batteryEnabled ["battery" "battery#percentage"];
      "tray" = {
        icon-size = 16;
        spacing = 8;
      };
      "custom/weather-temp" = {
        exec = "${weather-script} temp";
        return-type = "json";
        format = "{}";
        rotate = 270;
        interval = 600;
      };
      "custom/weather-icon" = {
        exec = "${weather-script} icon";
        return-type = "json";
        format = "{}";
        interval = 600;
      };
      ${workspacesModule.name} = workspacesModule.config;
      "clock#date" = {
        format = "{:%a %B %d}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        rotate = 270;
      };
      "clock#time" = {
        format = "{:%I:%M}";
      };
      "pulseaudio" = {
        format = "{icon}";
        format-bluetooth = "{icon}";
        format-muted = "";
        format-icons = {
          headphones = "";
          default = [""];
        };
        scroll-step = 1;
        on-click = "pavucontrol";
      };
      "pulseaudio#percentage" = {
        on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        format = "{volume}%";
      };
      "custom/mic" = {
        exec = "${mic-script}";
        return-type = "json";
        interval = 2;
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };
      "pulseaudio/slider" = {
        min = 0;
        max = 100;
        orientation = "vertical";
      };
      "network" = {
        format-wifi = "{icon}";
        format-ethernet = "󰈀";
        format-disconnected = "󰤭";
        format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        tooltip-format-wifi = "{essid} ({signalStrength}%)";
        tooltip-format-ethernet = "{ifname}: {ipaddr}";
        tooltip-format-disconnected = "Disconnected";
        interval = 5;
      };
      "network#percentage" = {
        format-wifi = "{signalStrength}%";
        format-ethernet = "";
        format-disconnected = "";
        interval = 5;
      };
    } // lib.optionalAttrs batteryEnabled {
      "battery" = {
        interval = 10;
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon}";
        format-charging = "󰂄";
        format-plugged = "󰚥";
        format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
      };
      "battery#percentage" = {
        interval = 10;
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{capacity}%";
        format-charging = "{capacity}%";
        format-plugged = "{capacity}%";
      };
    };

    # Emit a single bar object at the top level (waybar's expected schema).
    # Do NOT wrap in `{ mainBar = ...; }`: that's a home-manager convention,
    # and writing it raw makes waybar treat `mainBar` as an unknown key and
    # fall back to an empty default bar.
    barHyprland = mkBar { name = "hyprland/workspaces"; config = hyprlandWorkspaces; };
    barNiri     = mkBar { name = "niri/workspaces";     config = niriWorkspaces;     };

  in {
    # Install waybar + the session wrapper. We bypass programs.waybar.settings
    # so we can emit two config files (one per compositor).
    programs.waybar = {
      enable = true;
      systemd.enable = false;
    };

    home.packages = [ waybar-session ];

    xdg.configFile."waybar/config-hyprland.jsonc".text =
      builtins.toJSON barHyprland;
    xdg.configFile."waybar/config-niri.jsonc".text =
      builtins.toJSON barNiri;
  });
}
