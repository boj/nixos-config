{ config, lib, ... }:
let cfg = config.my.ssh; in {
  options.my.ssh.enable = lib.mkEnableOption "OpenSSH server";
  config = lib.mkIf cfg.enable {
    users.users.bojo.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICu6ak4iW3v0H7kRoSg/kVOnnO89fwri/6SDBIa6ir7n bojo@bruh"
    ];

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
