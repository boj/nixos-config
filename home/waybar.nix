{pkgs, config, ...}:

{
  programs.waybar = {
    enable = true;
    settings  = {
      mainBar = {
        layer = "top";
        position = "left";
        modules-left = [ "hyprland/workspaces" ];
        modules-right = [ "clock"];
        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            "1" = "I";
            "2" = "II";
            "3" = "III";
            "4" = "IV";
            "5" = "V";
            "6" = "VI";
            "7" = "VII";
            "8" = "VIII";
            "9" = "IX";
            "10" = "X";
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
          background-color: #E6E5E4;
          padding-right: 12px;
      }
      
      #waybar.stacked #window {
          background-color: #FFF;
          color: #FFF
      }
      
      #waybar.empty #window {
          color: #FFF;
          background-color: #fff;
      }
      
      #workspaces {
          color: #Fff;
          margin-left: 15px;
          margin-top: 15px;
          background-color: #323232;
          border-top-left-radius: 0;
          border-top-right-radius: 0;
      }
      
      #waybar {
          background-color: transparent;
      }
      
      #workspaces button {
        color: #Fff;
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
          color: #FFF;
          border-width: 1.5px;
          border-radius: 0;
          border-color: #FFF;
      }
      
      #custom-logout {
          font-family: Iosevka Slab;
          font-weight: normal;
          margin-bottom: 10px;
          margin-left: 15px;
      }
      
      #clock {
          margin-bottom: 20px;
          margin-left: 15px;
          font-family: Iosevka Slab;
          font-weight: normal;
          color: #242424;
      }
    '';
  };
}
