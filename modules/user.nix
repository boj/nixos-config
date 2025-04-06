{
  pkgs,
  username,
  ...
}: {
  programs.fish.enable = true;

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "docker"
      "input"
      "libvirtd"
      "plugdev"
      "sound"
      "tty"
      "video"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  nix.settings.trusted-users = ["${username}"];
}
