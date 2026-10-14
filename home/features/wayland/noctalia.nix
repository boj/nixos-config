{ config, lib, inputs, pkgs, ... }:
let cfg = config.my.wayland.noctalia; in {
  imports = [inputs.noctalia.homeModules.default];

  options.my.wayland.noctalia.enable = lib.mkEnableOption "Noctalia desktop shell (home)";

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
      };
    };
  };
}
