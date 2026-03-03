{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.wayland.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 1;
          width = 350;
          height = 150;
          origin = "top-right";
          offset = "20x20";
          corner_radius = 8;
          frame_width = 2;
          frame_color = "#${config.colorScheme.palette.base0E}";
          separator_color = "frame";
          font = "JetBrainsMono Nerd Font 11";
          padding = 12;
          horizontal_padding = 14;
          icon_position = "left";
          background = "#${config.colorScheme.palette.base00}";
          foreground = "#${config.colorScheme.palette.base05}";
        };

        urgency_low = {
          background = "#${config.colorScheme.palette.base01}";
          foreground = "#${config.colorScheme.palette.base05}";
          frame_color = "#${config.colorScheme.palette.base04}";
          timeout = 5;
        };

        urgency_normal = {
          background = "#${config.colorScheme.palette.base00}";
          foreground = "#${config.colorScheme.palette.base05}";
          frame_color = "#${config.colorScheme.palette.base0E}";
          timeout = 8;
        };

        urgency_critical = {
          background = "#${config.colorScheme.palette.base00}";
          foreground = "#${config.colorScheme.palette.base08}";
          frame_color = "#${config.colorScheme.palette.base08}";
          timeout = 0;
        };
      };
    };
  };
}
