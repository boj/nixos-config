{ config, lib, pkgs, ... }:
let cfg = config.my.wine; in {
  options.my.wine.enable = lib.mkEnableOption "Wine";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable
      wine
    ];
  };
}
