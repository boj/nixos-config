{config, ...}: {
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "left";
        modules-left = ["hyprland/workspaces"];
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

      #window {
          padding-left: 12px;
          background-color: #${config.colorScheme.palette.base02};
          padding-right: 12px;
      }

      #waybar.stacked #window {
          background-color: #${config.colorScheme.palette.base06};
          color: #${config.colorScheme.palette.base06};
      }

      #waybar.empty #window {
          color: #${config.colorScheme.palette.base06};
          background-color: #${config.colorScheme.palette.base06};
      }

      #workspaces {
          color: #${config.colorScheme.palette.base06};
          margin-left: 15px;
          margin-top: 15px;
          background-color: #${config.colorScheme.palette.base02};
          border-top-left-radius: 0;
          border-top-right-radius: 0;
      }

      #waybar {
          background-color: transparent;
      }

      #workspaces button {
        color: #${config.colorScheme.palette.base06};
        padding-bottom: 2px;
        padding-top: 2px;
        padding-left: 0px;
        padding-right: 0px;
        margin-top: 0.3rem;
        margin-bottom: 0.3rem;
        min-height: 0;
        border-radius: 0;
        min-width: 20px;
        border-radius: 2px;
        margin-left: 0.25rem;
        margin-right: 0.25rem;
      }

      #workspaces button.active {
          color: #${config.colorScheme.palette.base08};
          border-width: 1.5px;
          border-radius: 0;
          border-color: #${config.colorScheme.palette.base0D};
      }

      #clock {
          margin-bottom: 20px;
          margin-left: 15px;
          font-family: Iosevka Slab;
          font-weight: normal;
          color: #${config.colorScheme.palette.base05};
      }
    '';
  };
}
