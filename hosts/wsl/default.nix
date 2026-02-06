{ username, ... }: {
  my.virtualization.docker.enable = true;

  wsl.enable = true;
  wsl.defaultUser = username;
  networking.hostName = "mta-wsl";
  system.stateVersion = "23.11";
}
