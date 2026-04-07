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
        "swww-daemon"
        "waybar"
      ] ++ config.my.wayland.hyprland.execOnce;

      source = ["~/.config/hypr/matugen-colors.conf"];

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
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        layout = "dwindle";
      };

      group = {
        groupbar = {
          height = 2;
          render_titles = false;
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
          "easeOut, 0.25, 1, 0.5, 1"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "linear, 0, 0, 1, 1"
        ];
        animation = [
          "windowsIn, 1, 4, easeOut, slide"
          "windowsOut, 1, 3, smoothOut, slide"
          "fadeIn, 1, 4, easeOut"
          "fadeOut, 1, 3, smoothOut"
          "workspaces, 1, 5, easeOut, slide"
          "borderangle, 1, 60, linear, loop"
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
