{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.wayland.slate;

  # slate-session mirrors the shape of waybar-session so it can be dropped
  # into `my.wayland.waybarSessionPackage` without changing hyprland/niri
  # autostart wiring. Both compositors already `lib.getExe` this package.
  # QT_QPA_PLATFORM is forced to wayland so manual invocations from an
  # xcb-hostile shell env don't accidentally spawn a floating X11 window.
  slate-session = pkgs.writeShellScriptBin "slate-session" ''
    export QT_QPA_PLATFORM=wayland
    exec ${pkgs.quickshell}/bin/qs -c slate
  '';

  # Normalize persistentWorkspaces: an int value N becomes [1..N], a list
  # is kept as-is. Produces `{ "MON" = [ids...]; ... }` with all values as lists.
  normalizedPersistent = lib.mapAttrs (_: v:
    if builtins.isInt v then lib.range 1 v else v
  ) cfg.persistentWorkspaces;

  # Emit a QML object literal fragment for the persistent workspaces map,
  # keyed by monitor name. "*" is a wildcard used at lookup time in QML for
  # any monitor that doesn't have an explicit entry.
  qmlPersistentPairs = lib.concatStringsSep ",\n        " (
    lib.mapAttrsToList (name: ids:
      ''"${name}": [${lib.concatStringsSep ", " (map toString ids)}]''
    ) normalizedPersistent
  );

  configQml = ''
    pragma Singleton

    import QtQuick
    import Quickshell

    // Auto-generated from Nix — edit my.wayland.slate.* options and rebuild.
    // Provides Nix-derived configuration to QML at a stable, reactive-friendly
    // location. Keeps QML free of hardcoded per-machine constants.
    Singleton {
        // Show the battery widget in the bottom zone. Defaults to inherit
        // from `my.wayland.battery.enable`.
        readonly property bool showBattery: ${lib.boolToString cfg.showBattery}

        // Map of monitor name -> list of workspace IDs to always render as
        // slots in the workspace strip, even when unpopulated. The special
        // key "*" is used as fallback for monitors without an explicit entry.
        readonly property var persistentWorkspaces: ({
            ${qmlPersistentPairs}
        })
    }
  '';
in {
  # Declared here (rather than in the disabled waybar.nix) so kanshi,
  # hyprland, and niri can reference an absolute session-bar path regardless
  # of which bar implementation is active. Kept read-only + defaulted to
  # slate-session; other bar modules can `mkForce` a different package.
  options.my.wayland.waybarSessionPackage = lib.mkOption {
    type = lib.types.package;
    default = slate-session;
    defaultText = lib.literalExpression "slate-session";
    description = ''
      Package providing the compositor session bar wrapper. Exposed so
      other modules can reference its absolute path (via `lib.getExe`)
      instead of relying on PATH lookup at compositor startup.
    '';
  };

  options.my.wayland.slate = {
    enable = lib.mkEnableOption "Slate — vertical Quickshell bar (replaces waybar)";

    showBattery = lib.mkOption {
      type = lib.types.bool;
      default = config.my.wayland.battery.enable or false;
      defaultText = lib.literalExpression "config.my.wayland.battery.enable";
      description = "Show the battery indicator in the bottom zone.";
    };

    persistentWorkspaces = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.int (lib.types.listOf lib.types.int));
      default =
        if config.my.wayland.hyprland.enable or false
        then config.my.wayland.hyprland.waybarPersistentWorkspaces
        else {"*" = 5;};
      defaultText = lib.literalExpression ''
        Inherits from `my.wayland.hyprland.waybarPersistentWorkspaces` when
        hyprland is enabled, else `{ "*" = 5; }`.
      '';
      description = ''
        Per-monitor workspace slots to always render, even when empty.
        Value is either a count N (expands to [1..N]) or an explicit list
        of workspace IDs. The special key "*" is a fallback for monitors
        without their own entry.
      '';
      example = {
        "DP-1" = [1 2 3];
        "DP-2" = [4 5 6];
        "eDP-1" = 5;
      };
    };
  };

  config = lib.mkIf (config.my.wayland.enable && cfg.enable) {
    home.packages = [
      pkgs.quickshell
      slate-session
    ];

    # QML tree lives at ~/.config/quickshell/slate/ (matches `qs -c slate`).
    # Every file is nix-managed EXCEPT Colors.qml, which is owned by matugen
    # and seeded on first activation (see slatePaletteBootstrap below and the
    # matugen template registration in wayland/default.nix).
    #
    # Singletons live at the root (Colors.qml, Dimensions.qml, Config.qml,
    # Workspaces.qml) so QML's implicit same-dir import picks them up.
    # `Colors` (not `Palette`) because `Palette` collides with QtQuick's
    # built-in type and gets shadowed.
    xdg.configFile = {
      "quickshell/slate/shell.qml".source = ./qml/shell.qml;
      "quickshell/slate/Bar.qml".source = ./qml/Bar.qml;
      "quickshell/slate/Dimensions.qml".source = ./qml/Dimensions.qml;
      "quickshell/slate/Workspaces.qml".source = ./qml/Workspaces.qml;
      "quickshell/slate/Config.qml".text = configQml;

      "quickshell/slate/zones/TopZone.qml".source = ./qml/zones/TopZone.qml;
      "quickshell/slate/zones/MiddleZone.qml".source = ./qml/zones/MiddleZone.qml;
      "quickshell/slate/zones/BottomZone.qml".source = ./qml/zones/BottomZone.qml;

      "quickshell/slate/widgets/Clock.qml".source = ./qml/widgets/Clock.qml;
      "quickshell/slate/widgets/WorkspaceStrip.qml".source = ./qml/widgets/WorkspaceStrip.qml;
      "quickshell/slate/widgets/Battery.qml".source = ./qml/widgets/Battery.qml;
      "quickshell/slate/widgets/Volume.qml".source = ./qml/widgets/Volume.qml;
      "quickshell/slate/widgets/Microphone.qml".source = ./qml/widgets/Microphone.qml;
      "quickshell/slate/widgets/Tray.qml".source = ./qml/widgets/Tray.qml;
      # Colors.qml intentionally omitted — matugen owns it.
    };

    # Systemd user unit that owns the Slate lifecycle. Started as part of
    # graphical-session.target (both hyprland and niri home-manager modules
    # wire their own *-session.target into it), and restarted by sd-switch
    # on every `nixos-rebuild switch` where any QML input changes — the
    # X-Restart-Triggers hash below folds every managed file into the
    # unit's stored hash so home-manager notices.
    systemd.user.services.slate = {
      Unit = {
        Description = "Slate — Quickshell status bar";
        Documentation = ["https://quickshell.outfoxxed.me/"];
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        X-Restart-Triggers = [
          (builtins.hashString "sha256" (builtins.concatStringsSep ":" [
            (builtins.hashFile "sha256" ./qml/shell.qml)
            (builtins.hashFile "sha256" ./qml/Bar.qml)
            (builtins.hashFile "sha256" ./qml/Dimensions.qml)
            (builtins.hashFile "sha256" ./qml/Workspaces.qml)
            configQml
            (builtins.hashFile "sha256" ./qml/zones/TopZone.qml)
            (builtins.hashFile "sha256" ./qml/zones/MiddleZone.qml)
            (builtins.hashFile "sha256" ./qml/zones/BottomZone.qml)
            (builtins.hashFile "sha256" ./qml/widgets/Clock.qml)
            (builtins.hashFile "sha256" ./qml/widgets/WorkspaceStrip.qml)
            (builtins.hashFile "sha256" ./qml/widgets/Battery.qml)
            (builtins.hashFile "sha256" ./qml/widgets/Volume.qml)
            (builtins.hashFile "sha256" ./qml/widgets/Microphone.qml)
            (builtins.hashFile "sha256" ./qml/widgets/Tray.qml)
          ]))
        ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe slate-session}";
        Restart = "on-failure";
        RestartSec = 2;
        Slice = "session.slice";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    # Seed Colors.qml with sensible defaults on activation. Runs before
    # matugenInit and OVERWRITES an existing file when the seed source is
    # newer, so template/schema changes propagate on rebuild without needing
    # to manually `rm ~/.config/quickshell/slate/Colors.qml`.
    home.activation.slatePaletteBootstrap = lib.hm.dag.entryBefore ["matugenInit"] ''
      mkdir -p "$HOME/.config/quickshell/slate"
      SEED=${./qml/Colors.default.qml}
      TARGET="$HOME/.config/quickshell/slate/Colors.qml"
      if [ ! -f "$TARGET" ] || [ "$SEED" -nt "$TARGET" ]; then
        install -m 0644 "$SEED" "$TARGET"
      fi
      # Clean up stale Palette.qml from the pre-rename era so it doesn't
      # sit around confusing anyone.
      rm -f "$HOME/.config/quickshell/slate/Palette.qml"
    '';
  };
}
