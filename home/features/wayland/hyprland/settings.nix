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
        "swww-daemon"
      ] ++ config.my.wayland.hyprland.execOnce;

      input = {
        kb_layout = "us";
        kb_options = "ctrl:nocaps";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = false;
        };
        sensitivity = 0.0;
        scroll_factor = 1.0;
        emulate_discrete_scroll = 2;
        repeat_delay = 200;
        repeat_rate = 50;
      };

      misc = {
        key_press_enables_dpms = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        background_color = "rgb(${config.lib.stylix.colors.base01})";
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(${config.lib.stylix.colors.base08}ee) rgba(${config.lib.stylix.colors.base0A}ee) 45deg";
        "col.inactive_border" = "rgba(${config.lib.stylix.colors.base03}aa)";
        layout = "dwindle";
      };

      group = {
        "col.border_active" = "rgba(${config.lib.stylix.colors.base07}ee) rgba(${config.lib.stylix.colors.base0F}ee) 45deg";
        "col.border_inactive" = "rgba(${config.lib.stylix.colors.base0E}aa)";
        groupbar = {
          height = 2;
          render_titles = false;
          "col.active" = "rgba(${config.lib.stylix.colors.base0F}ee) rgba(${config.lib.stylix.colors.base07}ee) 45deg";
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
        bezier = [
          "overshoot, 0.05, 0.9, 0.1, 1.1"
          "smoothOut, 0.36, 0, 0.66, -0.56"
        ];
        animation = [
          "windowsIn, 1, 5, overshoot, popin 80%"
          "windowsOut, 1, 4, smoothOut, popin 80%"
          "fadeIn, 1, 5, overshoot"
          "fadeOut, 1, 4, smoothOut"
          "workspaces, 1, 6, overshoot, slide"
        ];
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
