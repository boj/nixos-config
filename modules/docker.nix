{pkgs, ...}: {
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
  users.extraGroups.docker.members = ["bojo"];
}
