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
  boot.resumeDevice = "/dev/disk/by-uuid/919c6432-cc35-4991-9ef5-9b9a300dac2f";
  boot.kernelParams = ["resume=/dev/disk/by-uuid/919c6432-cc35-4991-9ef5-9b9a300dac2f"];
  networking.hostName = "worky";
  programs.dconf.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  services.logind.settings.Login.HandlePowerKey = "hibernate";
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "2h";
    SuspendEstimationSec = "2h";
  };

  # Restart networking and tailscale after hibernate/suspend
  powerManagement.resumeCommands = ''
    systemctl restart NetworkManager
    sleep 5
    tailscale down
    tailscale up
  '';

  system.stateVersion = "23.11";
}
