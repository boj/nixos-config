{
  imports = [
    ./hardware-configuration.nix
    ../../lib/defaultProfile.nix
  ];

  # Host-specific
  my.gpu = "nvidia";
  my.wifi.enable = true;
  my.power.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "worky";
  programs.dconf.enable = true;

  # Never sleep — long-running tasks must not be interrupted
  services.logind.settings.Login.HandleLidSwitch = "lock";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";
  services.logind.settings.Login.HandlePowerKey = "lock";
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "23.11";
}
