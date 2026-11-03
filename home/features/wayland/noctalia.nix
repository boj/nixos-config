{ config, lib, inputs, pkgs, ... }:
let cfg = config.my.wayland.noctalia; in {
  imports = [inputs.noctalia.homeModules.default];

  options.my.wayland.noctalia.enable = lib.mkEnableOption "Noctalia desktop shell (home)";

  options.my.wayland.noctalia.location = {
    address = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "Palmer, AK";
      description = ''
        Address/city used by Noctalia's location service to resolve
        coordinates (geocoding). Shared by weather, night light, and theme
        auto mode. When empty, the manual latitude/longitude are used instead.
      '';
    };

    latitude = lib.mkOption {
      type = lib.types.float;
      default = config.my.wayland.weather.latitude;
      description = "Manual latitude fallback for the location service.";
    };

    longitude = lib.mkOption {
      type = lib.types.float;
      default = config.my.wayland.weather.longitude;
      description = "Manual longitude fallback for the location service.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Theme Noctalia via its own built-in palette, matching how this repo
    # drives the rest of the Wayland shell (Stylix targets are disabled and
    # theming is handled by the shell itself). Without this, Stylix's noctalia
    # target forces theme.source = "custom" and conflicts with the setting below.
    stylix.targets.noctalia.enable = false;

    programs.noctalia = {
      enable = true;
      # Launched by Umbriel's autostart, not a standalone systemd user service.
      systemd.enable = false;
      settings = {
        shell.font = "JetBrainsMono Nerd Font";
        # Location service: single source of "where am I", shared by weather,
        # night light, and theme auto mode. Disable IP auto-locate so the
        # per-host address (or manual coordinates) is authoritative.
        location = {
          auto_locate = false;
          address = cfg.location.address;
          latitude = cfg.location.latitude;
          longitude = cfg.location.longitude;
        };
        # Display temperatures in Fahrenheit.
        weather.unit = "imperial";
        # Edge rail: full-height, flush to the left edge, with the inner
        # corners carved concave so the bar flows into the window area. The
        # screen-corner side stays square.
        bar.main = {
          position = "left";
          thickness = 40;
          margin_edge = 0;
          margin_ends = 0;
          radius = 18;
          radius_top_left = 0;
          radius_bottom_left = 0;
          concave_edge_corners = true;
          background_opacity = 0.92;
          compositor_blur = true;
          shadow = true;
          padding = 12;
          widget_spacing = 8;
        };
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };
        # Lock screen context. The login box (bottom bar) auto-seeds per output
        # with now-playing media, weather + forecast, and the password field.
        # On top of that we float a clock, volume, system-monitor, and audio
        # visualizer. Positions are authored against a 1920x1080 reference via
        # placement_width/placement_height; Noctalia rescales them to each
        # host's actual output resolution.
        lockscreen_widgets = {
          enabled = true;
          widget_order = [
            "clock_main"
            "volume_main"
            "sysmon_main"
            "visualizer_main"
          ];
          widget = {
            clock_main = {
              type = "clock";
              cx = 960.0;
              cy = 190.0;
              placement_width = 1920.0;
              placement_height = 1080.0;
              settings = {
                format = "{:%H:%M}";
                show_seconds = false;
                background = true;
                background_opacity = 0.92;
              };
            };
            volume_main = {
              type = "volume";
              cx = 835.0;
              cy = 360.0;
              placement_width = 1920.0;
              placement_height = 1080.0;
              settings = {
                background = true;
                background_opacity = 0.92;
              };
            };
            sysmon_main = {
              type = "sysmon";
              cx = 1085.0;
              cy = 360.0;
              placement_width = 1920.0;
              placement_height = 1080.0;
              settings = {
                stat = "cpu_usage";
                stat2 = "cpu_temp";
                display = "graph";
                background = true;
                background_opacity = 0.92;
              };
            };
            visualizer_main = {
              type = "audio_visualizer";
              cx = 960.0;
              cy = 620.0;
              placement_width = 1920.0;
              placement_height = 1080.0;
              settings = {
                bands = 48;
                mirrored = true;
                centered = true;
                background = false;
              };
            };
          };
        };
      };
    };
  };
}
