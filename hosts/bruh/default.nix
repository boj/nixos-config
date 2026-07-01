{
  imports = [
    ./hardware-configuration.nix
    ../../lib/defaultProfile.nix
  ];

  # Host-specific
  my.steam.enable = true;
  my.attic.server.enable = true;

  # Firewall — open syslog port for SIEM-Daimon, Enshrouded game server
  networking.firewall.allowedUDPPorts = [5514 15637];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = ["i2c-dev" "i2c-piix4"];
  networking.hostName = "bruh";
  programs.dconf.enable = true;
  system.stateVersion = "23.11";
}
