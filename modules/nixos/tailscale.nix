{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.tailscale;
in {
  options.my.tailscale.enable = lib.mkEnableOption "Tailscale";
  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      #extraUpFlags = [
      #  "--ssh"
      #];
      #extraSetFlags = [
      #  "--accept-routes"
      #];
    };

    environment.systemPackages = with pkgs; [
      tailscale
    ];
  };
}
