{ config, lib, username, ... }:
let cfg = config.my.virtualization.virtualbox; in {
  options.my.virtualization.virtualbox.enable = lib.mkEnableOption "VirtualBox";
  config = lib.mkIf cfg.enable {
    virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = [username];
  };
}
