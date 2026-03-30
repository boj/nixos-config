{pkgs, config, ...}: {
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

  programs.btop = {
    enable = true;
    package = if config.my.gpu == "amd" then pkgs.btop-rocm else pkgs.btop;
    settings = {
      color_theme = "catppuccin_mocha";
      theme_background = false;
      vim_keys = true;
      shown_boxes = "cpu mem net proc gpu0";
      show_gpu_info = "On";
    };
  };

  xdg.configFile."btop/themes/catppuccin_mocha.theme".source =
    pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "btop";
      rev = "1.0.0";
      hash = "sha256-J3UezOQMDdxpflGax0rGBF/XMiKqdqZXuX4KMVGTxFk=";
    }
    + "/themes/catppuccin_mocha.theme";

  home.sessionVariables = {
    FZF_DEFAULT_COMMAND = "rg --files --hidden";
  };
}
