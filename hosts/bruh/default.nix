{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ../../modules/system.nix
      ../../modules/openrgb.nix
      ../../modules/steam.nix

      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "bruh";

  fileSystems."/mnt/data0" = {
    device = "192.168.1.96:/mnt/data0";
    fsType = "nfs";
  };

  system.stateVersion = "23.11";
}

