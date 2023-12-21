{pkgs, ...}: {
  programs.fish.enable = true;

  users.users.bojo = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "docker"
      "input"
      "sound"
      "tty"
      "video"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  nix.settings.trusted-users = ["bojo"];
}
