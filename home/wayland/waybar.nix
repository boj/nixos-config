{config, ...}: {
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "left";
        width = 40;
        margin-top = 8;
        margin-bottom = 8;
        spacing = 15;
        modules-left = ["hyprland/window"];
        modules-center = ["hyprland/workspaces"];
        modules-right = ["clock"];
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
        "hyprland/window" = {
          format = "{initialTitle}";
          max-length = 50;
          rotate = 270;
        };
        "clock" = {
          format = "{:%R}";
          tooltip-format = "{:%A, %B, %d, %Y}";
          tooltip = true;
        };
      };
    };
    style = ''
      * {
          font-family: Iosevka;
          font-weight: bold;
          font-size: 12px;
          margin: 0;
      }

      window#waybar {
          background-color: #${config.colorScheme.palette.base02};
          border-top-right-radius: 12px;
          border-bottom-right-radius: 12px;
      }

      window#waybar.hidden {
        opacity: 0;
      }

      #window {
        padding: 100px 20px;
        color: #${config.colorScheme.palette.base0A};
      }

      #workspaces button {
        padding: 10px 0px;
        background-color: transparent;
        color: #${config.colorScheme.palette.base06};
      }

      #worksapces button.persistent {
        padding: 10px 0px;
        background-color: transparent;
        color: #${config.colorScheme.palette.base05};
     }

      #workspaces button.hover {
          color: #${config.colorScheme.palette.base09};
      }

      #workspaces button.active {
          color: #${config.colorScheme.palette.base08};
      }

      #clock {
          margin-bottom: 20px;
          font-family: Iosevka Slab;
          font-weight: normal;
          color: #${config.colorScheme.palette.base05};
      }

      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }
    '';
  };
}
