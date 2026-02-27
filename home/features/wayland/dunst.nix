{
  config,
  lib,
  pkgs,
  ...
}: let
  claude-notify = pkgs.writeShellScriptBin "claude-notify" ''
    export PATH="${lib.makeBinPath (with pkgs; [coreutils jq libnotify])}"

    # Read hook JSON from stdin
    input=$(cat)

    # Extract fields from hook JSON
    cwd=$(echo "$input" | jq -r '.cwd // empty')
    hook_type=$(echo "$input" | jq -r '.type // "stop"')

    # Derive project name from cwd
    project=""
    if [ -n "$cwd" ]; then
      project=$(basename "$cwd")
    fi

    case "$hook_type" in
      notification)
        summary="Claude Code''${project:+ ($project)}"
        body="Needs attention"
        urgency="normal"
        ;;
      *)
        summary="Claude Code''${project:+ ($project)}"
        body="Response complete"
        urgency="low"
        ;;
    esac

    notify-send -a claude-code -u "$urgency" "$summary" "$body"
  '';
in {
  config = lib.mkIf config.my.wayland.enable {
    home.packages = [claude-notify];

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
          frame_color = "#${config.colorScheme.palette.base0E}";
          separator_color = "frame";
          font = "JetBrainsMono Nerd Font 11";
          padding = 12;
          horizontal_padding = 14;
          icon_position = "left";
          background = "#${config.colorScheme.palette.base00}";
          foreground = "#${config.colorScheme.palette.base05}";
        };

        urgency_low = {
          background = "#${config.colorScheme.palette.base01}";
          foreground = "#${config.colorScheme.palette.base05}";
          frame_color = "#${config.colorScheme.palette.base04}";
          timeout = 5;
        };

        urgency_normal = {
          background = "#${config.colorScheme.palette.base00}";
          foreground = "#${config.colorScheme.palette.base05}";
          frame_color = "#${config.colorScheme.palette.base0E}";
          timeout = 8;
        };

        urgency_critical = {
          background = "#${config.colorScheme.palette.base00}";
          foreground = "#${config.colorScheme.palette.base08}";
          frame_color = "#${config.colorScheme.palette.base08}";
          timeout = 0;
        };

        "claude-code" = {
          appname = "claude-code";
          frame_color = "#${config.colorScheme.palette.base0B}";
          foreground = "#${config.colorScheme.palette.base0B}";
          format = "<b>%s</b>\\n%b";
          timeout = 10;
        };
      };
    };
  };
}
