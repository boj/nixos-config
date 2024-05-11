{config, ...}: {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    monitor = [
      "DP-1,1920x1080@240,0x0,1,bitdepth,10"
      "DP-3,1920x1080@240,1920x0,1,bitdepth,10"
    ];

    workspace = [
      "1,monitor:DP-1,default:true"
      "2,monitor:DP-1"
      "3,monitor:DP-1"
      "4,monitor:DP-1"
      "5,monitor:DP-1"

      "6,monitor:DP-3,default:true"
      "7,monitor:DP-3"
      "8,monitor:DP-3"
      "9,monitor:DP-3"
      "10,monitor:DP-3"
    ];

    exec-once = [
      "dunst"
      "waybar"
      "hyprpaper"

      "[workspace 1 silent] firefox"
      "[workspace 6 silent] discord"
      "[workspace 6 silent] wezterm start btop"
      "[workspace 10 silent] qbittorrent"
    ];

    input = {
      kb_layout = "us";
      follow_mouse = 1;
      touchpad = {
        natural_scroll = false;
      };
      sensitivity = -0.5;
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
      cursor_inactive_timeout = 2;
      no_cursor_warps = true;
    };

    group = {
      "col.border_active" = "rgba(${config.colorScheme.palette.base07}ee) rgba(${config.colorScheme.palette.base0F}ee) 45deg";
      "col.border_inactive" = "rgba(${config.colorScheme.palette.base0E}aa)";
      groupbar = {
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
      drop_shadow = true;
      shadow_ignore_window = true;
      shadow_offset = "0 2";
      shadow_range = 10;
      shadow_render_power = 2;
      "col.shadow" = "rgba(${config.colorScheme.palette.base0D}dd)";
    };

    animations = {
      enabled = true;
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
      no_gaps_when_only = 0;
      force_split = 2;
    };

    master = {
      new_is_master = true;
      no_gaps_when_only = 0;
      mfact = 0.3;
    };

    gestures = {
      workspace_swipe = false;
    };
  };
}
