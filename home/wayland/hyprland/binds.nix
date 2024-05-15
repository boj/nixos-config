let
  workspaces = builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
      ]
    )
    10);
in {
  wayland.windowManager.hyprland.settings = {
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bind =
      [
        "$mod, RETURN, exec, wezterm"
        # "$mod, D, exec, wofi -f --show run --lines=5 --prompt=\"\""
        "$mod, D, exec, wofi -f --show=drun --lines=5 --prompt=\"\""
        "$mod SHIFT, D, exec, grimblast copy area"
        "$mod SHIFT, F, exec, grimblast copysave output ~/.screenshots/$(date +'%s_hypr.png')"
        "$mod SHIFT, G, exec, grimblast copy active"
        "$mod CTRL, P, exec, swayidle timeout 2 'sleep 1; hyprctl dispatcher dpms off' resume 'hyprctl dispatcher dpms on & pkill swayidle'"

        "$mod SHIFT, Q, killactive,"
        "$mod CTRL, E, exit,"
        "$mod, SPACE, togglesplit,"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating,"
        "$mod, P, pseudo,"

        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        "$mod ALT, H, resizeactive, -10 0"
        "$mod ALT, L, resizeactive, 10 0"
        "$mod ALT, K, resizeactive, 0 -10"
        "$mod ALT, J, resizeactive, 0 10"

        "$mod, E, togglegroup"
        "$mod SHIFT, E, lockactivegroup, toggle"
        "$mod, TAB, changegroupactive, f"
        "$mod SHIFT, TAB, changegroupactive, b"
        "$mod CTRL, L, moveoutofgroup, r"
        "$mod CTRL, H, moveoutofgroup, l"

        "$mod, Prior, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        "$mod, Next, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ]
      ++ workspaces;
  };
}
