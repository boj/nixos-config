{pkgs, ...}: {
  imports = [
    ./fastfetch.nix
    ./fish.nix
    ./git.nix
    ./starship.nix
  ];

  home.packages = with pkgs; [
    # compression
    unzip
    zip

    # utils
    alsa-utils
    duf
    fd
    fzf
    jq
    mplayer
    ripgrep
    socat
    usbutils
    xdg-utils

    # cli
    bat
    btop
    eza

    # fonts
    fira-code
    fira-code-symbols
    font-awesome
    iosevka
    noto-fonts
    noto-fonts-emoji
    powerline-fonts
    powerline-symbols
  ];

  home.sessionVariables = {
    FZF_DEFAULT_COMMAND = "rg --files --hidden";
  };
}
