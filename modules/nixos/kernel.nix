{ config, lib, pkgs, ... }:
let cfg = config.my.kernel; in {
  options.my.kernel.enable = lib.mkEnableOption "custom kernel settings";
  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.ip_forward" = 1;
    };
    boot.blacklistedKernelModules = [
      "hid_logitech_hidpp"
    ];
  };
}
