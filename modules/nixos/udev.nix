{ config, lib, ... }:
let cfg = config.my.udev; in {
  options.my.udev.enable = lib.mkEnableOption "udev rules";
  config = lib.mkIf cfg.enable {
    services.udev.extraRules = builtins.readFile ./data/50-zsa.rules;
  };
}
