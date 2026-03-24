{username, ...}: {
  my.ai.enable = true;
  my.tailscale.enable = true;
  my.virtualization.docker.enable = true;

  wsl.enable = true;
  wsl.defaultUser = username;
  networking.hostName = "brojo-wsl";
  system.stateVersion = "23.11";
}
