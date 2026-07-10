{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.wayland.niri;

  # Screenshot+annotate helper (mirrors hyprland's $mod SHIFT D/F/G keybinds).
  satty-area = pkgs.writeShellScript "niri-screenshot-area" ''
    set -e
    F=/tmp/satty-screenshot.png
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$F"
    ${pkgs.satty}/bin/satty --filename "$F" --copy-command wl-copy --early-exit \
      --actions-on-enter save-to-clipboard --actions-on-enter exit
  '';
  satty-screen = pkgs.writeShellScript "niri-screenshot-screen" ''
    set -e
    F=/tmp/satty-screenshot.png
    ${pkgs.grim}/bin/grim "$F"
    ${pkgs.satty}/bin/satty --filename "$F" --copy-command wl-copy --early-exit \
      --actions-on-enter save-to-clipboard --actions-on-enter exit
  '';

  toggle-mute = pkgs.writeShellScript "niri-toggle-mute" ''
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

  # Build workspace switch/move binds 1-9 (or F1-F9), matching hyprland binds.nix.
  workspaceKey = n:
    if cfg.useFunctionKeys then "F${toString n}" else toString n;

  workspaceBinds =
    lib.listToAttrs (lib.concatLists (map (n: [
      {
        name = "Mod+${workspaceKey n}";
        value.action.focus-workspace = toString n;
      }
      {
        name = "Mod+Shift+${workspaceKey n}";
        value.action.move-column-to-workspace = toString n;
      }
    ]) (lib.range 1 9)));

  baseBinds = {
    # Launchers
    "Mod+Return".action.spawn = "ghostty";
    "Mod+D".action.spawn = config.my.wayland.launcher.drun;

    # Screenshots (mirroring hyprland $mod SHIFT D/F/G)
    "Mod+Shift+D".action.spawn = ["${satty-area}"];
    "Mod+Shift+F".action.spawn = ["${satty-screen}"];
    "Mod+Shift+G".action.screenshot-window = [];

    # Session / lock / sleep
    "Mod+Ctrl+L".action.spawn = "hyprlock";
    "Mod+Ctrl+P".action.power-off-monitors = [];
    "Mod+Ctrl+Alt+P".action.spawn = ["sh" "-c" "hyprlock & sleep 1 && systemctl hibernate"];
    "Mod+Ctrl+Alt+S".action.spawn = ["sh" "-c" "hyprlock & sleep 1 && systemctl suspend"];
    "Mod+Ctrl+E".action.quit.skip-confirmation = true;

    # Window state
    "Mod+Shift+Q".action.close-window = [];
    "Mod+F".action.maximize-column = [];
    "Mod+Shift+Return".action.fullscreen-window = [];
    "Mod+V".action.toggle-window-floating = [];
    "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [];
    "Mod+Space".action.switch-preset-column-width = [];
    "Mod+P".action.switch-preset-window-height = [];

    # Focus (HJKL like vim/hyprland). J/K fall through to the adjacent
    # workspace when there's no window above/below.
    "Mod+H".action.focus-column-left = [];
    "Mod+L".action.focus-column-right = [];
    "Mod+K".action.focus-window-or-workspace-up = [];
    "Mod+J".action.focus-window-or-workspace-down = [];

    # Move
    "Mod+Shift+H".action.move-column-left = [];
    "Mod+Shift+L".action.move-column-right = [];
    "Mod+Shift+K".action.move-window-up-or-to-workspace-up = [];
    "Mod+Shift+J".action.move-window-down-or-to-workspace-down = [];

    # Resize (Alt+HJKL like hyprland)
    "Mod+Alt+H".action.set-column-width = "-10%";
    "Mod+Alt+L".action.set-column-width = "+10%";
    "Mod+Alt+K".action.set-window-height = "-10%";
    "Mod+Alt+J".action.set-window-height = "+10%";

    # Column/tab navigation (hyprland TAB → next group member)
    "Mod+Tab".action.focus-workspace-down = [];
    "Mod+Shift+Tab".action.focus-workspace-up = [];

    # Move workspace between monitors (hyprland $mod CTRL [/])
    "Mod+Ctrl+bracketleft".action.move-workspace-to-monitor-left = [];
    "Mod+Ctrl+bracketright".action.move-workspace-to-monitor-right = [];
    "Mod+Ctrl+Shift+bracketleft".action.move-column-to-monitor-left = [];
    "Mod+Ctrl+Shift+bracketright".action.move-column-to-monitor-right = [];

    # Overview replaces our custom wofi workspace-overview script.
    "Mod+O".action.toggle-overview = [];

    # Audio
    "Mod+Prior".action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"];
    "Mod+Next".action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
    "Mod+M".action.spawn = ["${toggle-mute}"];
    "Mod+Shift+M".action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];

    # Wallpaper picker
    "Mod+W".action.spawn = "skwd-wall-toggle";

    # XF86 media keys
    "XF86AudioRaiseVolume" = {
      allow-when-locked = true;
      action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"];
    };
    "XF86AudioLowerVolume" = {
      allow-when-locked = true;
      action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
    };
    "XF86AudioMute" = {
      allow-when-locked = true;
      action.spawn = ["${toggle-mute}"];
    };
    "XF86AudioMicMute" = {
      allow-when-locked = true;
      action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
    };
    "XF86MonBrightnessUp" = {
      allow-when-locked = true;
      action.spawn = ["brightnessctl" "set" "5%+"];
    };
    "XF86MonBrightnessDown" = {
      allow-when-locked = true;
      action.spawn = ["brightnessctl" "set" "5%-"];
    };
    "XF86AudioPlay".action.spawn = ["playerctl" "play-pause"];
    "XF86AudioPrev".action.spawn = ["playerctl" "previous"];
    "XF86AudioNext".action.spawn = ["playerctl" "next"];
  };
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings.binds = baseBinds // workspaceBinds;
  };
}
