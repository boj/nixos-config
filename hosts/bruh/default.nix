{
  imports = [
    ./hardware-configuration.nix
    ../../lib/defaultProfile.nix
  ];

  # Host-specific
  my.steam.enable = true;
  my.enshrouded.enable = true;

  # Firewall — open syslog port for SIEM-Daimon
  networking.firewall.allowedUDPPorts = [5514];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = ["i2c-dev" "i2c-piix4"];
  # Reserve the 4K page containing the bad RAM cell found by memtest86+
  # (failing address 0x48ad4cab8 ~18.1GB) so the kernel never allocates it.
  boot.kernelParams = ["memmap=4K$0x48ad4c000"];
  networking.hostName = "bruh";
  programs.dconf.enable = true;
  system.stateVersion = "23.11";
}
