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
          frame_color = "#${config.lib.stylix.colors.base0E}";
          separator_color = "frame";
          font = "JetBrainsMono Nerd Font 11";
          padding = 12;
          horizontal_padding = 14;
          icon_position = "left";
          background = "#${config.lib.stylix.colors.base00}";
          foreground = "#${config.lib.stylix.colors.base05}";
        };

        urgency_low = {
          background = "#${config.lib.stylix.colors.base01}";
          foreground = "#${config.lib.stylix.colors.base05}";
          frame_color = "#${config.lib.stylix.colors.base04}";
          timeout = 5;
        };

        urgency_normal = {
          background = "#${config.lib.stylix.colors.base00}";
          foreground = "#${config.lib.stylix.colors.base05}";
          frame_color = "#${config.lib.stylix.colors.base0E}";
          timeout = 8;
        };

        urgency_critical = {
          background = "#${config.lib.stylix.colors.base00}";
          foreground = "#${config.lib.stylix.colors.base08}";
          frame_color = "#${config.lib.stylix.colors.base08}";
          timeout = 0;
        };
      };
    };
  };
}
