{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.wayland.niri;
  hypr = config.my.wayland.hyprland;

  # --- Helpers: translate Hyprland monitor/workspace strings to niri schema ---

  # Hyprland monitor strings have the form:
  #   "<name>,<W>x<H>@<R>,<X>x<Y>,<S>"
  # where <name> may be a plain connector ("DP-1") or "desc:<descriptor>".
  parseMonitor = str: let
    parts = lib.splitString "," str;
    rawName = lib.elemAt parts 0;
    name =
      if lib.hasPrefix "desc:" rawName
      then lib.removePrefix "desc:" rawName
      else rawName;
    mode = lib.elemAt parts 1;
    posStr = lib.elemAt parts 2;
    scaleStr = lib.elemAt parts 3;

    modeParts = lib.splitString "@" mode;
    res = lib.splitString "x" (lib.elemAt modeParts 0);
    refresh = lib.elemAt modeParts 1;

    pos = lib.splitString "x" posStr;
  in {
    inherit name;
    value = {
      mode = {
        width = lib.toInt (lib.elemAt res 0);
        height = lib.toInt (lib.elemAt res 1);
        refresh = lib.toIntBase10 (lib.head (lib.splitString "." refresh)) * 1.0;
      };
      position = {
        x = lib.toInt (lib.elemAt pos 0);
        y = lib.toInt (lib.elemAt pos 1);
      };
      scale = lib.toIntBase10 scaleStr * 1.0;
    };
  };

  outputsFromHypr =
    lib.listToAttrs (map parseMonitor hypr.monitors);

  # Hyprland workspace strings:
  #   "<n>, monitor:<name-or-desc>[, default:true][, ...]"
  parseWorkspace = str: let
    # Split on commas but preserve "monitor:desc:Make Model Serial" — split only on the first 3 segments.
    raw = lib.splitString "," str;
    name = lib.strings.trim (lib.elemAt raw 0);
    monitorSeg =
      lib.findFirst (s: lib.hasPrefix "monitor:" (lib.strings.trim s)) null raw;
    monitor =
      if monitorSeg == null
      then null
      else let
        v = lib.removePrefix "monitor:" (lib.strings.trim monitorSeg);
      in
        if lib.hasPrefix "desc:" v then lib.removePrefix "desc:" v else v;
  in {
    inherit name;
    value =
      lib.optionalAttrs (monitor != null) {open-on-output = monitor;};
  };

  workspacesFromHypr =
    lib.listToAttrs (map parseWorkspace hypr.workspaces);

  # Parse exec-once entries like "[workspace 1 silent] chromium" → spawn "chromium".
  parseSpawn = str: let
    trimmed = lib.strings.trim str;
    stripped =
      if lib.hasPrefix "[" trimmed
      then let
        afterBracket = lib.elemAt (lib.splitString "]" trimmed) 1;
      in
        lib.strings.trim afterBracket
      else trimmed;
  in {
    command = ["sh" "-c" stripped];
  };

  # Niri's exec-once analogue. Always include the same baseline as hyprland
  # (waybar, dunst, awww-daemon) so the bar/notifications/wallpaper come up.
  baselineSpawns = [
    {command = ["dunst"];}
    {command = ["awww-daemon"];}
    {command = [(lib.getExe config.my.wayland.waybarSessionPackage)];}
  ];
  hyprlandExecOnceSpawns = map parseSpawn hypr.execOnce;
  extraSpawns = map (s: {command = ["sh" "-c" s];}) cfg.execOnce;

  hypridleSpawn =
    lib.optional (hypr.idleTimeout != null) {command = ["hypridle"];};

  finalOutputs =
    if cfg.outputs == {} then outputsFromHypr else cfg.outputs;

  finalWorkspaces =
    if cfg.workspaces == {} then workspacesFromHypr else cfg.workspaces;
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings = {
      # Use Super as the primary modifier, matching Hyprland's $mod = SUPER.
      input = {
        keyboard = {
          xkb = {
            layout = "us";
            options = "ctrl:nocaps";
          };
          repeat-delay = 200;
          repeat-rate = 50;
        };
        touchpad = {
          tap = true;
          natural-scroll = false;
        };
        mouse = {
          accel-speed = 0.0;
        };
        focus-follows-mouse.enable = true;
        warp-mouse-to-focus.enable = false;
      };

      outputs = finalOutputs;

      workspaces = finalWorkspaces;

      layout = {
        gaps = 20;
        center-focused-column = "never";
        preset-column-widths = [
          {proportion = 1.0 / 3.0;}
          {proportion = 1.0 / 2.0;}
          {proportion = 2.0 / 3.0;}
        ];
        default-column-width = {proportion = 1.0 / 2.0;}; # ~hyprland dwindle force_split=2
        border = {
          enable = true;
          width = 2;
        };
        focus-ring = {
          enable = true;
          width = 2;
        };
        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };
      };

      prefer-no-csd = true;

      # Required for X11 apps (Steam, many games, OBS pre-Wayland builds, etc).
      # Niri has no built-in XWayland — xwayland-satellite is a separate
      # daemon that niri spawns and manages, exposing a DISPLAY for X11 apps.
      xwayland-satellite = {
        enable = true;
        path = lib.getExe pkgs.xwayland-satellite-unstable;
      };

      cursor = {
        hide-when-typing = true;
      };

      # Niri's overview replaces our custom workspace-overview wofi script.
      overview = {
        backdrop-color = "#000000";
      };

      hotkey-overlay = {
        skip-at-startup = true;
      };

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      animations = {
        enable = true;
        # Slightly snappier than defaults to feel similar to hyprland easeOut.
        slowdown = 1.0;
      };

      window-rules = [
        # Match hyprland's rounded corners on tiled windows.
        {
          geometry-corner-radius = let r = 10.0; in {
            top-left = r;
            top-right = r;
            bottom-left = r;
            bottom-right = r;
          };
          clip-to-geometry = true;
        }
        # Satty floating + centered, matching hyprland rules.nix.
        {
          matches = [{app-id = "^com\\.gabm\\.satty$";}];
          open-floating = true;
        }
        # Open Chromium and Vesktop at full column width so they fill the
        # screen on launch (with niri's gaps acting as padding).
        {
          matches = [
            {app-id = "^chromium(-browser)?$";}
            {app-id = "^[Vv]esktop$";}
            {app-id = "^dev\\.vencord\\.Vesktop$";}
          ];
          default-column-width = {proportion = 1.0;};
        }
      ];

      spawn-at-startup =
        baselineSpawns
        ++ hyprlandExecOnceSpawns
        ++ extraSpawns
        ++ hypridleSpawn;

      environment = {
        # Critical for screencasting under niri — ensures portal selection
        # uses GNOME/niri ScreenCast, not wlr.
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
        # Match hyprland's session feel.
        NIXOS_OZONE_WL = "1";
        WLR_RENDERER = "vulkan";
        GTK_USE_PORTAL = "1";
        NIXOS_XDG_OPEN_USE_PORTAL = "1";
      };
    };
  };
}
