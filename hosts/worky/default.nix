{
  imports = [./hardware-configuration.nix];

  # Feature flags
  my.ai.enable = true;
  my.gpu = "nvidia";
  my.greet.enable = true;
  my.hyprland.enable = true;
  my.kernel.enable = true;
  my.sound.enable = true;
  my.ssh.enable = true;
  my.steam.enable = true;
  my.tailscale.enable = true;
  my.udev.enable = true;
  my.wifi.enable = true;
  my.power.enable = true;
  my.wine.enable = false;
  my.xdg.enable = true;
  my.rust.enable = true;
  my.virtualization.docker.enable = true;

  # Host-specific
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
