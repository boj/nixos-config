{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.wayland.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      "$mod" = "SUPER";

      monitor = config.my.wayland.hyprland.monitors;

      workspace = config.my.wayland.hyprland.workspaces;

      exec-once = [
        "dunst"
        "waybar"
        "hyprpaper"

        "[workspace 1 silent] firefox"
        "[workspace 6 silent] discord"
        "[workspace 6 silent] kitty btop"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = false;
        };
        sensitivity = -0.5;
        scroll_factor = 0.75;
        emulate_discrete_scroll = 2;
        repeat_delay = 200;
        repeat_rate = 50;
      };

      misc = {
        key_press_enables_dpms = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        background_color = "rgb(${config.colorScheme.palette.base01})";
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(${config.colorScheme.palette.base08}ee) rgba(${config.colorScheme.palette.base0A}ee) 45deg";
        "col.inactive_border" = "rgba(${config.colorScheme.palette.base03}aa)";
        layout = "dwindle";
      };

      group = {
        "col.border_active" = "rgba(${config.colorScheme.palette.base07}ee) rgba(${config.colorScheme.palette.base0F}ee) 45deg";
        "col.border_inactive" = "rgba(${config.colorScheme.palette.base0E}aa)";
        groupbar = {
          height = 2;
          render_titles = false;
          "col.active" = "rgba(${config.colorScheme.palette.base0F}ee) rgba(${config.colorScheme.palette.base07}ee) 45deg";
          "col.inactive" = "rgba(aaaaaaee)";
        };
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          brightness = 0.5;
          contrast = 1.0;
          noise = 0.2;
          size = 5;
          passes = 3;
        };
        shadow = {
          enabled = true;
          ignore_window = true;
          offset = "0 2";
          range = 10;
          render_power = 2;
        };
      };

      animations = {
        enabled = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
      };

      master = {
        mfact = 0.3;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
    };
  };
}
