{
  imports = [
    ../../modules/docker.nix
    ../../modules/greet.nix
    ../../modules/kernel.nix
    #../../modules/openrgb.nix
    ../../modules/plex.nix
    ../../modules/sound.nix
    ../../modules/steam.nix
    ../../modules/system.nix
    ../../modules/udev.nix
    ../../modules/user.nix
    ../../modules/virtualization.nix
    ../../modules/wine.nix
    ../../modules/xdg.nix

    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = ["i2c-dev" "i2c-piix4"];

  networking.hostName = "bruh";

  fileSystems."/mnt/data0" = {
    device = "192.168.1.96:/mnt/data0";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  programs.dconf.enable = true;

  system.stateVersion = "23.11";
}
