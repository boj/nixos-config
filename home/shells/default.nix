{pkgs, ...}: {
  imports = [
    ./fish.nix
    ./git.nix
    ./starship.nix
  ];

  home.packages = with pkgs; [
    # compression
    unzip
    zip

    # utils
    duf
    fd
    fzf
    ripgrep
    usbutils
    xdg-utils

    # cli
    bat
    btop
    eza
    fastfetch
  ];

  home.sessionVariables = {
    FZF_DEFAULT_COMMAND = "rg --files --hidden";
  };
}
