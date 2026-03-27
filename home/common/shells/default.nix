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

    # dev
    devenv

    # utils
    alsa-utils
    duf
    fd
    fzf
    jq
    mplayer
    ncdu
    ripgrep
    socat
    usbutils
    xdg-utils

    # cli
    bat
    btop-rocm
    eza

    # fonts
    fira-code
    fira-code-symbols
    font-awesome
    iosevka
    nerd-fonts.droid-sans-mono
    noto-fonts
    noto-fonts-color-emoji
    powerline-fonts
    powerline-symbols
  ];

  home.sessionVariables = {
    FZF_DEFAULT_COMMAND = "rg --files --hidden";
  };
}
