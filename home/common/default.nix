{username, ...}: {
  imports = [
    ./editors
    ./gpu.nix
    ./shells
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.claude/bin"
    "$HOME/.npm-packages/bin"
  ];

  home.stateVersion = "23.11";

  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;
}
