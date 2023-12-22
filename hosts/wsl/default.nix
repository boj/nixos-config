{
  imports = [
    ../../modules/docker.nix
    ../../modules/system.nix
    ../../modules/user.nix

    # ./hardware-configuration.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "bojo";

  networking.hostName = "mta-wsl";

  system.stateVersion = "23.11";
}
