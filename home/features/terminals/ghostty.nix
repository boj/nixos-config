{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.terminals.ghostty;
in {
  options.my.terminals.ghostty.enable = lib.mkEnableOption "Ghostty terminal";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ghostty
    ];

    programs.ghostty = {
      enable = true;
      settings = {
        "font-family" = "JetBrainsMono Nerd Font";
        "font-size" = 11;
        "theme" = "Catppuccin Mocha";
        "background-opacity" = 0.5;
        "background-blur-radius" = 5;
        "window-padding-x" = 10;
        "window-padding-y" = 10;
        "confirm-close-surface" = false;
        "mouse-hide-while-typing" = true;
      };
    };
  };
}
