{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.wayland.ags;
  system = pkgs.stdenv.hostPlatform.system;
in {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  options.my.wayland.ags.enable = lib.mkEnableOption "AGS popup widgets";

  config = lib.mkIf cfg.enable {
    programs.ags = {
      enable = true;
      configDir = ./ags-widgets;
      extraPackages = [
        inputs.astal.packages.${system}.notifd
        inputs.astal.packages.${system}.wireplumber
      ];
    };
  };
}
