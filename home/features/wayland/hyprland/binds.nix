{
  config,
  lib,
  pkgs,
  ...
}: let
  workspaces = builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, F${ws}, workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
      ]
    )
    10);

  workspace-overview = pkgs.writeShellScript "workspace-overview" ''
    export PATH="${lib.makeBinPath (with pkgs; [coreutils jq hyprland procps gitMinimal gnused wofi])}"

    # Walk process tree to find the deepest descendant (the shell or its child)
    find_leaf() {
      local p=$1
      local child
      while true; do
        child=$(pgrep -P "$p" | tail -1)
        [ -z "$child" ] && break
        p=$child
      done
      echo "$p"
    }

    build_entries() {
      hyprctl clients -j | jq -r '.[] | select(.workspace.id > 0) | [.workspace.id, .pid, .class, .title] | @tsv' | sort -t$'\t' -k1 -n | while IFS=$'\t' read -r ws pid class title; do
        project=""
        cwd=""

        case "$class" in
          ghostty|kitty|org.wezfurlong.wezterm|Alacritty|foot)
            leaf_pid=$(find_leaf "$pid")
            cwd=$(readlink "/proc/$leaf_pid/cwd" 2>/dev/null)
            ;;
          *)
            cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null)
            ;;
        esac

        if [ -n "$cwd" ]; then
          git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
          if [ -n "$git_root" ]; then
            project=$(basename "$git_root")
          else
            project=$(basename "$cwd")
          fi
        fi

        if [ -n "$project" ]; then
          echo "WS $ws | $project ($class)"
        else
          echo "WS $ws | $title ($class)"
        fi
      done
    }

    selected=$(build_entries | wofi --dmenu --prompt "Workspaces")
    [ -z "$selected" ] && exit 0

    ws_num=$(echo "$selected" | sed 's/WS \([0-9]*\) .*/\1/')
    hyprctl dispatch workspace "$ws_num"
  '';
in {
  config = lib.mkIf config.my.wayland.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bind =
        [
          "$mod, RETURN, exec, ghostty"
          # "$mod, D, exec, wofi -f --show run --lines=5 --prompt=\"\""
          "$mod, D, exec, wofi -f --show=drun"
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

          "$mod, O, exec, ${workspace-overview}"
        ]
        ++ workspaces;
    };
  };
}
