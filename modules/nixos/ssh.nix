{ config, lib, username, sshKeys, ... }:
let cfg = config.my.ssh; in {
  options.my.ssh.enable = lib.mkEnableOption "OpenSSH server";
  config = lib.mkIf cfg.enable {
    users.users.${username}.openssh.authorizedKeys.keys = sshKeys;

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    programs.mosh.enable = true;
  };
}
