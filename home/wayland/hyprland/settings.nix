{config, ...}: {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    monitor = [
      "DP-1,1920x1080@240,0x0,1"
      "DP-3,1920x1080@240,1920x0,1"
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
      "[workspace 6 silent] kitty btop"
      "[workspace 10 silent] qbittorrent"

      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
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
    };

    #cursor = {
    #  inactive_timeout = 2;
    #  no_warps = true;
    #};

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
        # "col.shadow" = "rgba(${config.colorScheme.palette.base0D}dd)";
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

    gestures = {
      workspace_swipe = false;
    };

    ecosystem = {
      no_update_news = true;
      no_donation_nag = true;
    };
  };
}
