{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.printer;
in {
  options.my.services.printer.enable = lib.mkEnableOption "Auto Discovery of Printers";

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
    };
  };
}
