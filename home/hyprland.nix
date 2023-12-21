{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    dunst
    grim
    slurp
    swayidle
    waybar
    wl-clipboard
    wofi
  ];
	
  wayland.windowManager.hyprland = {
		enable = true;
		extraConfig = ''
      monitor=DP-1,1920x1080@240,0x0,1
      monitor=DP-3,1920x1080@240,1920x0,1
      
      workspace=1,monitor:DP-1,default:true
      workspace=2,monitor:DP-1
      workspace=3,monitor:DP-1
      workspace=4,monitor:DP-1
      workspace=5,monitor:DP-1
      
      workspace=6,monitor:DP-3,default:true
      workspace=7,monitor:DP-3
      workspace=8,monitor:DP-3
      workspace=9,monitor:DP-3
      workspace=10,monitor:DP-3
      
      exec-once = dunst
      exec-once = waybar
      
      exec-once=[workspace 1 silent] firefox
      exec-once=[workspace 6 silent] discord
      exec-once=[workspace 6 silent] wezterm start btop
      exec-once=[workspace 9 silent] easyeffects
      exec-once=[workspace 10 silent] qbittorrent
      
      env = XCURSOR_SIZE,24
      
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =
      
          follow_mouse = 1
      
          touchpad {
              natural_scroll = false
          }
      
          sensitivity = -0.5 # -1.0 - 1.0, 0 means no modification.
      
          repeat_delay = 200
          repeat_rate = 50
      }
      
      misc {
          #mouse_move_enables_dpms = true
          key_press_enables_dpms = true
      
          disable_hyprland_logo = true
          disable_splash_rendering = true
          background_color = rgb(3b4252)
      }
      
      general {
          gaps_in = 5
          gaps_out = 20
          border_size = 2
          col.active_border = rgba(d8dee9ee) rgba(eceff4ee) 45deg
          col.inactive_border = rgba(4c566aaa)
      
          cursor_inactive_timeout = 2
      
          layout = dwindle
      }
      
      group {
          col.border_active = rgba(8fbcbbee) rgba(5e81acee) 45deg
          col.border_inactive = rgba(b48eadaa)
      
          groupbar {
              render_titles = false
              col.active = rgba(5e81acee) rgba(8fbcbbee) 45deg
              col.inactive = rgba(aaaaaaee)
          }
      }
      
      decoration {
          rounding = 10
      
          blur {
              enabled = true
              size = 3
              passes = 1
          }
      
          drop_shadow = true
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(81a1c1dd)
      }
      
      animations {
          enabled = true
      }
      
      dwindle {
          pseudotile = true # master switch for pseudotiling. Enabling is bound to mod + P in the keybinds section below
          preserve_split = true # you probably want this
          no_gaps_when_only = 0
          force_split = 2
      }
      
      master {
          new_is_master = true
          no_gaps_when_only = 0
          mfact = 0.3
      }
      
      gestures {
          workspace_swipe = false
      }
      
      device:epic-mouse-v1 {
          sensitivity = -0.5
      }

      $mod = SUPER
      
      bind = $mod, RETURN, exec, wezterm
      bind = $mod, D, exec, wofi -f --show run --lines=5 --prompt=""
      bind = $mod SHIFT, D, exec, shot.sh crop
      bind = $mod SHIFT, F, exec, shot.sh full DP-1
      bind = $mod SHIFT, G, exec, shot.sh full DP-3
      bind = $mod CTRL, P, exec, swayidle timeout 2 'sleep 1; hyprctl dispatcher dpms off' resume 'hyprctl dispatcher dpms on & pkill swayidle'
      
      bind = $mod SHIFT, Q, killactive,
      bind = $mod CTRL, E, exit,
      bind = $mod, SPACE, togglesplit, # dwindle
      bind = $mod, F, fullscreen
      bind = $mod, V, togglefloating,
      bind = $mod, P, pseudo, # dwindle
      
      bind = $mod, H, movefocus, l
      bind = $mod, L, movefocus, r
      bind = $mod, K, movefocus, u
      bind = $mod, J, movefocus, d
      
      bind = $mod SHIFT, H, movewindow, l
      bind = $mod SHIFT, L, movewindow, r
      bind = $mod SHIFT, K, movewindow, u
      bind = $mod SHIFT, J, movewindow, d
      
      bind = $mod ALT, H, resizeactive, -10 0
      bind = $mod ALT, L, resizeactive, 10 0
      bind = $mod ALT, K, resizeactive, 0 -10
      bind = $mod ALT, J, resizeactive, 0 10
      
      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5
      bind = $mod, 6, workspace, 6
      bind = $mod, 7, workspace, 7
      bind = $mod, 8, workspace, 8
      bind = $mod, 9, workspace, 9
      bind = $mod, 0, workspace, 10
      
      bind = $mod SHIFT, 1, movetoworkspacesilent, 1
      bind = $mod SHIFT, 2, movetoworkspacesilent, 2
      bind = $mod SHIFT, 3, movetoworkspacesilent, 3
      bind = $mod SHIFT, 4, movetoworkspacesilent, 4
      bind = $mod SHIFT, 5, movetoworkspacesilent, 5
      bind = $mod SHIFT, 6, movetoworkspacesilent, 6
      bind = $mod SHIFT, 7, movetoworkspacesilent, 7
      bind = $mod SHIFT, 8, movetoworkspacesilent, 8
      bind = $mod SHIFT, 9, movetoworkspacesilent, 9
      bind = $mod SHIFT, 0, movetoworkspacesilent, 10
      
      bind = $mod, E, togglegroup
      bind = $mod SHIFT, E, lockactivegroup, toggle
      bind = $mod, TAB, changegroupactive, f
      bind = $mod SHIFT, TAB, changegroupactive, b
      bind = $mod CTRL, L, moveoutofgroup, r
      bind = $mod CTRL, H, moveoutofgroup, l
      
      bind = $mod, mouse_down, workspace, e+1
      bind = $mod, mouse_up, workspace, e-1
      
      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow
      
      bind = $mod, Prior, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bind = $mod, Next, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
		'';
  };
}
