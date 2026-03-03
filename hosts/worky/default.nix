{
  imports = [./hardware-configuration.nix];

  # Feature flags
  my.ai.enable = true;
  my.greet.enable = true;
  my.hyprland.enable = true;
  my.kernel.enable = true;
  my.sound.enable = true;
  my.ssh.enable = true;
  my.steam.enable = true;
  my.tailscale.enable = true;
  my.udev.enable = true;
  my.wine.enable = false;
  my.xdg.enable = true;
  my.rust.enable = true;
  my.virtualization.docker.enable = true;

  # Host-specific
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "worky";
  programs.dconf.enable = true;
  system.stateVersion = "23.11";
}
