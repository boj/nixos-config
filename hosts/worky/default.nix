{
  imports = [
    ./hardware-configuration.nix
    ../../lib/defaultProfile.nix
  ];

  # Host-specific
  my.wifi.enable = true;
  my.power.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "worky";
  programs.dconf.enable = true;

  # Hybrid Intel UHD 770 + NVIDIA RTX A4500 Laptop GPU.
  # PRIME offload keeps the desktop on Intel and lets specific apps run on
  # NVIDIA. The DaVinci Resolve wrapper that consumes this lives in
  # home/features/programs/desktop.nix (gated on my.gpu == "nvidia").
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

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
