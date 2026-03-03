{ config, lib, ... }:
let cfg = config.my.ssh; in {
  options.my.ssh.enable = lib.mkEnableOption "OpenSSH server";
  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
