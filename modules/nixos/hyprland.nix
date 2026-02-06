{ config, lib, inputs, ... }:
let cfg = config.my.hyprland; in {
  imports = [inputs.hyprland.nixosModules.default];
  options.my.hyprland.enable = lib.mkEnableOption "Hyprland";
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
  };
}
