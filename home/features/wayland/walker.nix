{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.wayland.walker;
in {
  options.my.wayland.walker = {
    enable = lib.mkEnableOption "walker application launcher";
    replaceWofi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When true, `my.wayland.launcher.*` resolves to walker commands so
        keybinds route through walker instead of wofi. Both binaries remain
        installed so ad-hoc invocations of either keep working.
      '';
    };
  };

  # Launcher abstraction used by hyprland/niri keybinds. Kept internal so
  # only the launcher modules touch it.
  options.my.wayland.launcher = {
    drun = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["wofi" "-f" "--show=drun"];
      description = "argv to open the application launcher.";
      internal = true;
    };
    dmenu = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.str);
      default = prompt: ["wofi" "--dmenu" "--prompt" prompt];
      defaultText = lib.literalExpression ''prompt: ["wofi" "--dmenu" "--prompt" prompt]'';
      description = "Function returning argv for a dmenu-style picker with the given prompt.";
      internal = true;
    };
  };

  config = lib.mkIf (config.my.wayland.enable && cfg.enable) (lib.mkMerge [
    {
      home.packages = with pkgs; [walker elephant];

      # Walker 2.x is a thin frontend; it talks to the `elephant` data
      # provider daemon over a Unix socket. Without elephant running,
      # walker exits after a few seconds with "Please install elephant."
      # Elephant must run in the graphical user session so it inherits
      # WAYLAND_DISPLAY, DBUS_SESSION_BUS_ADDRESS, etc. (see upstream
      # README: system-level services will not work).
      systemd.user.services.elephant = {
        Unit = {
          Description = "Elephant data provider daemon (walker backend)";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.elephant}/bin/elephant";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      # Walker 2.x is a GApplication service: `walker` is a client that
      # activates the running instance. Without the service, invocations
      # exit silently. Run it as a user service, activated on graphical
      # session start, after elephant is up.
      systemd.user.services.walker = {
        Unit = {
          Description = "Walker application launcher (service mode)";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target" "elephant.service"];
          Requires = ["elephant.service"];
        };
        Service = {
          ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      # Walker 2.x has a completely different config schema than 0.x.
      # Stick with defaults for now; add customization once we have a
      # reference for the 2.x schema.
    }

    (lib.mkIf cfg.replaceWofi {
      my.wayland.launcher = {
        drun = lib.mkForce ["walker"];
        dmenu = lib.mkForce (prompt: ["walker" "--dmenu" "--placeholder" prompt]);
      };
    })
  ]);
}
