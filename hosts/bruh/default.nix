{
  imports = [
    ../../modules/docker.nix
    ../../modules/kernel.nix
    #../../modules/openrgb.nix
    ../../modules/sound.nix
    ../../modules/steam.nix
    ../../modules/system.nix
    ../../modules/user.nix
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
  };

  system.stateVersion = "23.11";
}
