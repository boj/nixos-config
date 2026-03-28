{
  config,
  lib,
  pkgs,
  ...
}: let
  batteryEnabled = config.my.wayland.battery.enable;
in let
  weather-indicator = pkgs.writeShellScript "waybar-weather" ''
    export PATH="${lib.makeBinPath (with pkgs; [curl coreutils jq])}"

    DATA=$(curl -fsSL --max-time 10 "wttr.in/${config.my.wayland.weather.location}?format=j1" 2>/dev/null) || true

    if [ -z "$DATA" ] || ! echo "$DATA" | jq -e '.current_condition[0]' >/dev/null 2>&1; then
      echo '{"text":"--°F","tooltip":"Weather unavailable","class":"error"}'
      exit 0
    fi

    TEMP=$(echo "$DATA" | jq -r '.current_condition[0].temp_F')
    CONDITION=$(echo "$DATA" | jq -r '.current_condition[0].weatherDesc[0].value')
    FEELS_LIKE=$(echo "$DATA" | jq -r '.current_condition[0].FeelsLikeF')
    HUMIDITY=$(echo "$DATA" | jq -r '.current_condition[0].humidity')
    WIND_MPH=$(echo "$DATA" | jq -r '.current_condition[0].windspeedMiles')
    AREA=$(echo "$DATA" | jq -r '.nearest_area[0].areaName[0].value')
    REGION=$(echo "$DATA" | jq -r '.nearest_area[0].region[0].value')

    case "$CONDITION" in
      *Thunder*)        ICON="⛈" ;;
      *Snow*|*Blizzard*) ICON="❄" ;;
      *Sleet*|*Ice*)    ICON="🌨" ;;
      *Rain*|*Drizzle*|*Shower*) ICON="🌧" ;;
      *Fog*|*Mist*|*Haze*) ICON="🌫" ;;
      *Overcast*)       ICON="☁" ;;
      *Cloud*)          ICON="⛅" ;;
      *Sunny*|*Clear*)  ICON="☀" ;;
      *)                ICON="🌤" ;;
    esac

    TOOLTIP=$(printf "%s, %s\n%s\nFeels like: %s°F\nHumidity: %s%%\nWind: %s mph" \
      "$AREA" "$REGION" "$CONDITION" "$FEELS_LIKE" "$HUMIDITY" "$WIND_MPH")

    jq -nc --arg text "$TEMP°F $ICON" --arg tooltip "$TOOLTIP" \
      '{"text":$text,"tooltip":$tooltip,"class":"weather"}'
  '';
in {
  options.my.wayland.battery.enable = lib.mkEnableOption "battery indicator in waybar";

  options.my.wayland.weather.location = lib.mkOption {
    type = lib.types.str;
    default = "Eagle+River,Alaska";
    description = "Location for weather widget (wttr.in format)";
  };

  config = lib.mkIf config.my.wayland.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "left";
          margin-top = 8;
          margin-bottom = 8;
          margin-left = 8;
          reload_style_on_change = true;
          modules-left = ["custom/weather" "hyprland/workspaces"];
          modules-center = ["clock#date" "clock#time"];
          modules-right = ["pulseaudio/slider" "pulseaudio#percentage"]
            ++ lib.optionals batteryEnabled ["battery" "battery#percentage"];
          "custom/weather" = {
            exec = "${weather-indicator}";
            return-type = "json";
            format = "{}";
            rotate = 270;
            interval = 600;
          };
          "hyprland/workspaces" = {
            on-click = "activate";
            format = "{icon}";
            format-icons = {
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
              "10" = "0";
            };
            persistent-workspaces = {
              "*" = 5;
            };
          };
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
          "pulseaudio/slider" = {
            min = 0;
            max = 100;
            orientation = "vertical";
          };
          "battery" = lib.mkIf batteryEnabled {
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
          "battery#percentage" = lib.mkIf batteryEnabled {
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
      };
      # CSS managed by matugen (templates/waybar.css)
    };
  };
}
