{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.work;
in {
  options.my.programs.work.enable = lib.mkEnableOption "work programs";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      chromium
      microsoft-edge
      openfortivpn
    ];
  };
}
