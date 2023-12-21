{ default, ... }:

{
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
      "[workspace 6 silent] wezterm start btop"
      "[workspace 9 silent] easyeffects"
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
      background_color = "rgb(3b4252)";
    };
    
    general = {
      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      "col.active_border" = "rgba(bf616aee) rgba(ebcb8bee) 45deg";
      "col.inactive_border" = "rgba(4c566aaa)";
      cursor_inactive_timeout = 2;
      layout = "dwindle";
    };
    
    group = {
      "col.border_active" = "rgba(8fbcbbee) rgba(5e81acee) 45deg";
      "col.border_inactive" = "rgba(b48eadaa)";
      groupbar = {
        render_titles = false;
        "col.active" = "rgba(5e81acee) rgba(8fbcbbee) 45deg";
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
      shadow_render_power = 3;
      "col.shadow" = "rgba(81a1c1dd)";
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
    
    "device:epic-mouse-v1" = {
      sensitivity = -0.5;
    };
	};
}
