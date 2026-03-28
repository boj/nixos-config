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
      style = ''
        @define-color mainbg #${config.lib.stylix.colors.base00};
        @define-color modulesbg #${config.lib.stylix.colors.base01};
        @define-color text #${config.lib.stylix.colors.base05};
        @define-color empty #${config.lib.stylix.colors.base02};
        @define-color persistent #${config.lib.stylix.colors.base04};
        @define-color red #${config.lib.stylix.colors.base08};
        @define-color peach #${config.lib.stylix.colors.base09};
        @define-color yellow #${config.lib.stylix.colors.base0A};
        @define-color green #${config.lib.stylix.colors.base0B};
        @define-color teal #${config.lib.stylix.colors.base0C};
        @define-color blue #${config.lib.stylix.colors.base0D};
        @define-color mauve #${config.lib.stylix.colors.base0E};
        @define-color rosewater #${config.lib.stylix.colors.base06};
        @define-color lavender #${config.lib.stylix.colors.base07};

        * {
          all: initial;
          font-family:'JetBrainsMono Nerd Font';
          padding-left: 1px;
          padding-right: 1px;
        }

        window#waybar {
        	background: @mainbg;
        	border: 1px solid @lavender;
        	border-radius: 5px;
        }

        tooltip {
          background: #${config.lib.stylix.colors.base03};
          border: 2px solid @teal;
          border-radius: 5px;
          font-size: 12pt;
        }

        tooltip label {
          padding: 10px;
        }

        #custom-weather {
          font-size: 14px;
          padding: 20px 5px 10px 5px;
          color: @teal;
          background: @modulesbg;
          border-bottom: 3px solid @teal;
          border-bottom-left-radius: 5px;
          border-bottom-right-radius: 50px;
        }

        #workspaces {
          margin: 100px 0px 0px 0px;
          background: @modulesbg;
          font-size: 12pt;
          padding: 20px 0px;
          border-top:3px solid @blue;
          border-top-left-radius: 50px;
          border-top-right-radius: 5px;
          border-bottom: 3px solid @blue;
          border-bottom-right-radius: 50px;
          border-bottom-left-radius: 5px;
        }

        #workspaces button {
          font-size: 18pt;
          padding: 2px;
          margin: 5px 6px;
          border-radius: 10px;
        }

        #workspaces button.persistent {
          background-color: @persistent;
        }

        #workspaces button.empty {
          background-color: @empty;
        }

        #workspaces button.visible {
          background-color: @empty;
        }

        #workspaces button.active {
          background-color: @blue;
        }

        #workspaces button.urgent {
          background-color: @red;
        }

        #workspaces button:hover {
          background-color: @peach;
        }

        #pulseaudio, #clock, #clock.date, #clock.time {
          background: @modulesbg;
        }

        #pulseaudio {
          padding: 1px 5px 1px 5px;
          color: @text;
          font-size: 16px;
        }

        #clock.date {
          padding: 30px 5px 10px 5px;
          font-size: 14px;
          color: @rosewater;
          border-top:3px solid @mauve;
          border-top-left-radius: 50px;
          border-top-right-radius: 5px;
        }

        #clock.time {
          padding: 10px 5px 30px 5px;
          font-size: 14px;
          color: @teal;
          border-bottom: 3px solid @mauve;
          border-bottom-left-radius: 5px;
          border-bottom-right-radius: 50px;
        }

        #pulseaudio-slider, #pulseaudio.percentage, #battery, #battery.percentage {
          background-color: @modulesbg;
        }

        #pulseaudio-slider {
          padding: 15px 0px 5px 0px;
          border-top: 3px solid @peach;
          border-top-left-radius: 50px;
          border-top-right-radius: 5px;
        }
        #pulseaudio-slider slider {
            min-height: 0px;
            min-width: 1px;
            opacity: 0;
            background-image: none;
            border: none;
            box-shadow: none;
        }
        #pulseaudio-slider trough {
            min-height: 70px;
            min-width: 0px;
            border-radius: 5px;
            background-color: @peach;
        }
        #pulseaudio-slider highlight {
            min-width: 10px;
            border-radius: 5px;
            background-color: @teal;
        }

        #pulseaudio.percentage {
          font-size: 12px;
          margin: 0px 0px;
          padding: 2px 5px;
          color: @text;
        }

        #battery {
          padding: 10px 5px 1px 5px;
          color: @text;
          font-size: 16px;
        }

        #battery.charging {
          color: @green;
        }

        #battery.plugged {
          color: @green;
        }

        #battery.warning:not(.charging):not(.plugged) {
          color: @yellow;
        }

        #battery.critical:not(.charging):not(.plugged) {
          color: @red;
        }

        #battery.percentage {
          font-size: 12px;
          margin: 0px 0px;
          padding: 2px 5px 15px 5px;
          color: @text;
          border-bottom: 3px solid @peach;
          border-bottom-left-radius: 5px;
          border-bottom-right-radius: 50px;
        }

        #battery.percentage.warning:not(.charging):not(.plugged) {
          color: @yellow;
        }

        #battery.percentage.critical:not(.charging):not(.plugged) {
          color: @red;
        }
      '';
    };
  };
}
