{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.my.wayland.umbriel;

  # IPC helper for Noctalia shell actions bound to keys.
  noc = cmd: "spawn:noctalia msg ${cmd}";

  # Absolute binary paths for media-key spawns (session PATH is not guaranteed).
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";

  # Mute toggle that restores the pre-mute volume, matching the older Hyprland setup.
  toggle-mute = pkgs.writeShellScript "toggle-mute" ''
    export PATH="${lib.makeBinPath (with pkgs; [wireplumber coreutils gawk gnugrep])}"
    SAVE="''${XDG_RUNTIME_DIR:-/tmp}/volume-before-mute"
    STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    if echo "$STATUS" | grep -q MUTED; then
      VOL=$(cat "$SAVE" 2>/dev/null || echo "0.50")
      wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
      wpctl set-volume @DEFAULT_AUDIO_SINK@ "$VOL"
    else
      VOL=$(echo "$STATUS" | awk '{print $2}')
      echo "$VOL" > "$SAVE"
      wpctl set-volume @DEFAULT_AUDIO_SINK@ 0
      wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
    fi
  '';

  # Workspace switch / move-to-workspace binds for workspaces 1-9.
  wsBinds = lib.listToAttrs (lib.concatMap (n: [
    (lib.nameValuePair "Mod+${toString n}" "workspace-switch:${toString n}")
    (lib.nameValuePair "Mod+Shift+${toString n}" "window-move-to-workspace:${toString n}")
  ]) (lib.range 1 9));

  baseKeybinds = {
    # Applications and session
    "Mod+Return" = { action = "spawn:ghostty"; repeat = false; };
    "Mod+D" = { action = noc "panel-toggle launcher"; repeat = false; };
    "Mod" = noc "panel-toggle launcher";
    "Mod+N" = { action = noc "panel-toggle control-center"; repeat = false; };
    "Mod+C" = { action = noc "panel-toggle clipboard"; repeat = false; };
    "Mod+Escape" = { action = noc "panel-toggle session"; repeat = false; };
    "Mod+Ctrl+L" = { action = noc "session lock"; repeat = false; };
    "Mod+Q" = { action = "window-close"; repeat = false; };
    "Mod+Shift+Escape" = { action = "shortcuts-inhibit-toggle"; allow_when_inhibited = true; repeat = false; };

    # Screenshots (Noctalia capture + editor)
    "Mod+Shift+S" = { action = noc "screenshot-region"; repeat = false; };
    "Print" = { action = noc "screenshot-fullscreen"; repeat = false; };

    # Focus and movement
    "Mod+Left" = "window-focus-or-output-left";
    "Mod+Down" = "window-focus-or-output-down";
    "Mod+Up" = "window-focus-or-output-up";
    "Mod+Right" = "window-focus-or-output-right";
    "Mod+H" = "window-focus-or-output-left";
    "Mod+J" = "window-focus-or-output-down";
    "Mod+K" = "window-focus-or-output-up";
    "Mod+L" = "window-focus-or-output-right";
    "Mod+Shift+Left" = "column-move-left";
    "Mod+Shift+Down" = "window-move-down";
    "Mod+Shift+Up" = "window-move-up";
    "Mod+Shift+Right" = "column-move-right";

    # Window state and layout
    "Mod+V" = { action = "window-toggle-floating"; repeat = false; };
    "Mod+P" = { action = "window-toggle-pinned"; repeat = false; };
    "Mod+M" = { action = "window-toggle-maximize-to-edges"; repeat = false; };
    "Mod+F" = { action = "window-toggle-fullscreen"; repeat = false; };
    "Mod+R" = "window-cycle-primary-extent";
    "Mod+Shift+R" = "window-cycle-primary-extent-back";
    "Mod+Comma" = "window-consume-left";
    "Mod+Period" = "window-consume-right";
    "Mod+W" = { action = "column-toggle-tabbed"; repeat = false; };
    "Mod+O" = { action = "overview-toggle"; repeat = false; };

    # Scratchpad
    "Mod+Shift+Space" = { action = "window-move-to-scratchpad"; repeat = false; };
    "Mod+Space" = "scratchpad-toggle";
    "Mod+Tab" = "scratchpad-focus-next";

    # Audio (direct wpctl/playerctl, matching the older Hyprland media key binds)
    "XF86AudioRaiseVolume" = { action = "spawn:${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"; allow_when_locked = true; };
    "XF86AudioLowerVolume" = { action = "spawn:${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"; allow_when_locked = true; };
    "XF86AudioMute" = { action = "spawn:${toggle-mute}"; allow_when_locked = true; repeat = false; };
    "XF86AudioMicMute" = { action = "spawn:${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; allow_when_locked = true; repeat = false; };
    "XF86AudioPlay" = { action = "spawn:${playerctl} play-pause"; allow_when_locked = true; repeat = false; };
    "XF86AudioPrev" = { action = "spawn:${playerctl} previous"; allow_when_locked = true; repeat = false; };
    "XF86AudioNext" = { action = "spawn:${playerctl} next"; allow_when_locked = true; repeat = false; };

    # Brightness (direct brightnessctl, matching the older Hyprland media key binds)
    "XF86MonBrightnessUp" = { action = "spawn:${brightnessctl} set 5%+"; allow_when_locked = true; };
    "XF86MonBrightnessDown" = { action = "spawn:${brightnessctl} set 5%-"; allow_when_locked = true; };
  };

  baseSettings = {
    general.autostart = ["noctalia"] ++ cfg.autostart;

    appearance.blur.radius = 3;

    input.keyboard.numlock_toggle = true;

    layout = {
      extent_presets = [0.333 0.5 0.667];
      scrolling.default_extent_fraction = 0.5;
    };

    keybinds = baseKeybinds // wsBinds;

    window_rule = [
      { blur = true; blur_optimized = false; }
      {
        match.app_id = "^dev.noctalia.Noctalia$";
        default_floating = true;
        default_floating_size_px = { width = 1020; height = 900; };
      }
      {
        match.app_id = "^dev.noctalia.UmbrielSharePicker$";
        default_floating = true;
        default_floating_size_px = { width = 800; height = 600; };
      }
      {
        match.title = "^(Picture-in-Picture|Picture in picture)$";
        default_floating = true;
        default_maximize = false;
        default_position = { x = 20; y = 20; anchor = "bottom_right"; };
      }
    ];

    layer_rule = [{
      match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
      blur = true;
      blur_ignore_alpha = 0.5;
      blur_popups = true;
      blur_optimized = false;
    }];

    hot_corners.top_left = {
      enabled = true;
      delay_ms = 500;
      action = "overview-open";
    };
  };
in {
  imports = [inputs.umbriel.homeModules.default];

  options.my.wayland.umbriel = {
    enable = lib.mkEnableOption "Umbriel Wayland compositor (home)";

    outputs = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
      default = {};
      description = "Per-output configuration, emitted as [output.<name>] tables.";
      example = {
        "DP-1" = { mode = "1920x1080@240"; position = [0 0]; scale = 1; };
      };
    };

    autostart = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra commands to autostart with the session (Noctalia is always started).";
      example = ["[workspace 1 silent] chromium"];
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra settings deep-merged over Umbriel's config.toml defaults.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.umbriel = {
      enable = true;
      settings = lib.recursiveUpdate (baseSettings // { output = cfg.outputs; }) cfg.extraSettings;
    };

    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Umbriel";
      XDG_SESSION_DESKTOP = "Umbriel";
    };
  };
}
