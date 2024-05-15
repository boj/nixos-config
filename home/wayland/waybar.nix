{config, ...}: {
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
        modules-left = ["hyprland/workspaces"];
        modules-center = ["clock#date" "clock#time"];
        modules-right = ["pulseaudio/slider" "pulseaudio#percentage"];
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
        };
        "clock#date" = {
          format = "{:%a\n%d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        "clock#time" = {
          format = "{:%I\n%M}";
        };
        "pulseaudio" = {
          format = "{icon}";
          format-bluetooth = "{icon}";
          format-muted = "";
          format-icons = {
            headphones = "";
            default = [""];
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
      };
    };
    style = ''
      @define-color mainbg #${config.colorScheme.palette.base00};
      @define-color modulesbg #${config.colorScheme.palette.base02};
      @define-color text #${config.colorScheme.palette.base04};
      @define-color border #${config.colorScheme.palette.base0F};
      @define-color buttons #${config.colorScheme.palette.base08};
      @define-color hover #${config.colorScheme.palette.base09};
      @define-color white #${config.colorScheme.palette.base05};

      * {
        all: initial;
        font-family:'JetBrainsMono Nerd Font';
        padding-left: 1px;
        padding-right: 1px;
      }

      window#waybar {
      	background: @mainbg;
      	border: 1px solid @border;
      	border-radius: 5px;
      }

      tooltip {
        background: #${config.colorScheme.palette.base03};
        border: 2px solid #${config.colorScheme.palette.base0C};
        border-radius: 5px;
        font-size: 12pt;
      }

      tooltip label {
        padding: 10px;
      }

      #workspaces {
        margin: 10px 0px;
        background: @modulesbg;
        font-size: 12pt;
        padding: 20px 0px;
        border-top:3px solid @border;
        border-top-left-radius: 50px;
        border-top-right-radius: 5px;
        border-bottom: 3px solid @border;
        border-bottom-right-radius: 50px;
        border-bottom-left-radius: 5px;
      }

      #workspaces button {
        padding: 2px;
        margin: 5px 6px;
      }

      #workspaces button.active {
        background-color: @buttons;
        font-size: 18pt;
        border-top-right-radius: 5px;
        border-top-left-radius: 50px;
        border-bottom-right-radius: 50px;
        border-bottom-left-radius: 5px;
      }

      #workspaces button:hover {
        background: inherit;
        background-color: @hover;
        border-top-right-radius: 5px;
        border-top-left-radius: 50px;
        border-bottom-right-radius: 50px;
        border-bottom-left-radius: 5px;
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
        padding: 20px 5px 10px 5px;
        font-size: 14px;
        color: @text;
        border-top:3px solid @border;
        border-top-left-radius: 50px;
        border-top-right-radius: 5px;
      }

      #clock.time {
        padding: 10px 5px 20px 5px;
        font-size: 14px;
        color: @text;
        border-bottom: 3px solid @border;
        border-bottom-left-radius: 5px;
        border-bottom-right-radius: 50px;
      }

      #pulseaudio-slider, #pulseaudio.percentage {
        background-color: @modulesbg;
      }

      #pulseaudio-slider {
        padding: 15px 0px 5px 0px;
        border-top: 3px solid @border;
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
          background-color: @border;
      }
      #pulseaudio-slider highlight {
          min-width: 10px;
          border-radius: 5px;
          background-color: @white;
      }

      #pulseaudio.percentage {
        font-size: 12px;
        margin: 0px 0px;
        padding: 2px 5px;
        color: @text;
      }
    '';
  };
}
