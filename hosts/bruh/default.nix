{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ../../modules/kernel.nix
      ../../modules/user.nix
      ../../modules/system.nix
      ../../modules/openrgb.nix
      ../../modules/steam.nix

      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  networking.hostName = "bruh";

  fileSystems."/mnt/data0" = {
    device = "192.168.1.96:/mnt/data0";
    fsType = "nfs";
  };

  system.stateVersion = "23.11";
}

