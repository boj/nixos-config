{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.terminals.zellij;
in {
  options.my.terminals.zellij.enable = lib.mkEnableOption "Zellij terminal multiplexer";

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        theme = "stylix";
        themes.stylix = with config.lib.stylix.colors; {
          bg = "#${base01}";
          fg = "#${base04}";
          red = "#${base01}";
          green = "#${base01}";
          blue = "#${base01}";
          yellow = "#${base01}";
          magenta = "#${base01}";
          orange = "#${base01}";
          cyan = "#${base01}";
          black = "#${base00}";
          white = "#${base03}";
        };
      };
    };
  };
}
