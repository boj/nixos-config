{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.wayland.ags;
in {
  options.my.wayland.ags.enable = lib.mkEnableOption "AGS / HyprPanel";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ags
      bun
      hyprpanel
    ];
  };
}
