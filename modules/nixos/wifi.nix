{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.my.wifi;
in {
  options.my.wifi.enable = lib.mkEnableOption "WiFi via NetworkManager";

  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      wifi.scanRandMacAddress = true;
      wifi.powersave = true;
    };

    users.users.${username}.extraGroups = ["networkmanager"];

    environment.systemPackages = with pkgs; [
      networkmanager # nmcli, nmtui
    ];
  };
}
