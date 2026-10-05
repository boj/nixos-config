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
        bar.main.position = "left";
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };
      };
    };
  };
}
