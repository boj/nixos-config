{
  imports = [
    ./editors/helix.nix
    ./shells
  ];

  home.username = "bojo";
  home.homeDirectory = "/home/bojo";

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
