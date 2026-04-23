{
  imports = [
    ./hardware-configuration.nix
    ../../lib/defaultProfile.nix
  ];

  # Host-specific
  my.gpu = "amd";
  my.steam.enable = true;

  # Firewall — open syslog port for SIEM-Daimon
  networking.firewall.allowedUDPPorts = [5514];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = ["i2c-dev" "i2c-piix4"];
  networking.hostName = "bruh";
  programs.dconf.enable = true;
  system.stateVersion = "23.11";
}
