{
  config,
  lib,
  pkgs,
  ...
}: let
  batteryEnabled = config.my.wayland.battery.enable;
in let
  project-indicator = pkgs.writeShellScript "waybar-project-indicator" ''
    export PATH="${lib.makeBinPath (with pkgs; [coreutils jq hyprland socat procps gitMinimal])}"

    # Walk process tree to find the deepest descendant
    find_leaf() {
      local p=$1
      local child
      while true; do
        child=$(pgrep -P "$p" | tail -1)
        [ -z "$child" ] && break
        p=$child
      done
      echo "$p"
    }

    get_project() {
      local win_json pid class
      win_json=$(hyprctl activewindow -j 2>/dev/null) || return
      pid=$(echo "$win_json" | jq -r '.pid // empty')
      class=$(echo "$win_json" | jq -r '.class // empty')

      if [ -z "$pid" ] || [ "$pid" = "null" ]; then
        echo '{"text":"","class":"empty"}'
        return
      fi

      local cwd=""
      case "$class" in
        ghostty|kitty|org.wezfurlong.wezterm|Alacritty|foot)
          local leaf_pid
          leaf_pid=$(find_leaf "$pid")
          cwd=$(readlink "/proc/$leaf_pid/cwd" 2>/dev/null)
          ;;
        *)
          cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null)
          ;;
      esac

      if [ -z "$cwd" ]; then
        echo '{"text":"","class":"empty"}'
        return
      fi

      local git_root branch project_name
      git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)

      if [ -n "$git_root" ]; then
        project_name=$(basename "$git_root")
        branch=$(git -C "$git_root" symbolic-ref --short HEAD 2>/dev/null || git -C "$git_root" rev-parse --short HEAD 2>/dev/null)
        local tooltip="$project_name  $branch\n$git_root"
        printf '{"text":"%s","tooltip":"%s","class":"project"}\n' "$project_name" "$tooltip"
      else
        project_name=$(basename "$cwd")
        printf '{"text":"%s","tooltip":"%s","class":"directory"}\n' "$project_name" "$cwd"
      fi
    }

    # Initial output
    get_project

    # Listen to Hyprland socket2 events
    HYPRLAND_SOCKET2="''${XDG_RUNTIME_DIR}/hypr/''${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
    socat -u "UNIX-CONNECT:''${HYPRLAND_SOCKET2}" - | while IFS= read -r line; do
      case "$line" in
        activewindow\>\>*|workspace\>\>*|focusedmon\>\>*|openwindow\>\>*|closewindow\>\>*)
          get_project
          ;;
      esac
    done
  '';
in {
  options.my.wayland.battery.enable = lib.mkEnableOption "battery indicator in waybar";

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
          modules-left = ["custom/project" "hyprland/workspaces"];
          modules-center = ["clock#date" "clock#time"];
          modules-right = ["pulseaudio/slider" "pulseaudio#percentage"]
            ++ lib.optionals batteryEnabled ["battery" "battery#percentage"];
          "custom/project" = {
            exec = "${project-indicator}";
            return-type = "json";
            format = "{}";
            rotate = 270;
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
        @define-color mainbg #${config.colorScheme.palette.base00};
        @define-color modulesbg #${config.colorScheme.palette.base01};
        @define-color text #${config.colorScheme.palette.base05};
        @define-color empty #${config.colorScheme.palette.base02};
        @define-color persistent #${config.colorScheme.palette.base04};
        @define-color red #${config.colorScheme.palette.base08};
        @define-color peach #${config.colorScheme.palette.base09};
        @define-color yellow #${config.colorScheme.palette.base0A};
        @define-color green #${config.colorScheme.palette.base0B};
        @define-color teal #${config.colorScheme.palette.base0C};
        @define-color blue #${config.colorScheme.palette.base0D};
        @define-color mauve #${config.colorScheme.palette.base0E};
        @define-color rosewater #${config.colorScheme.palette.base06};
        @define-color lavender #${config.colorScheme.palette.base07};

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
          background: #${config.colorScheme.palette.base03};
          border: 2px solid @teal;
          border-radius: 5px;
          font-size: 12pt;
        }

        tooltip label {
          padding: 10px;
        }

        #custom-project {
          font-size: 12px;
          padding: 20px 5px 10px 5px;
          color: @text;
          background: @modulesbg;
          border-top: 3px solid @green;
          border-top-left-radius: 50px;
          border-top-right-radius: 5px;
        }

        #custom-project.project {
          color: @green;
          border-top-color: @green;
        }

        #custom-project.directory {
          color: @rosewater;
          border-top-color: @mauve;
        }

        #custom-project.empty {
          padding: 0;
          margin: 0;
          border: none;
          min-height: 0;
          min-width: 0;
          font-size: 0;
        }

        #workspaces {
          margin: 10px 0px;
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
