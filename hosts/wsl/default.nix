{username, ...}: {
  imports = [
    ../../modules/system.nix
    ../../modules/user.nix
    ../../modules/virtualization/docker.nix

    # ./hardware-configuration.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "${username}";

  networking.hostName = "mta-wsl";

  system.stateVersion = "23.11";
}
