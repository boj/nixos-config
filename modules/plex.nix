{username, ...}: {
  services.plex = {
    enable = true;
    openFirewall = true;
    user = "${username}";
  };
}
