{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.gaming;
in {
  options.my.programs.gaming.enable = lib.mkEnableOption "gaming and creative tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      blender
      godot_4
      lutris
      unityhub
    ];
  };
}
