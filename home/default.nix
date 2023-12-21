{ config, pkgs, inputs, ... }:

{
  imports = [
    ./fish.nix
    ./git.nix
    ./helix.nix
    ./hyprland
    ./waybar.nix
    ./wezterm.nix
    ./wofi.nix
  ];

  home.username = "bojo";
  home.homeDirectory = "/home/bojo";

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "wezterm";
    VISUAL = "hx";
    SDL_VIDEODRIVER = "wayland";
    WLR_RENDERER = "vulkan";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1";
    NIXOS_XDG_OPEN_USE_PORTAL = "1";
    QT_QPA_PLATFORM = "xcb"; # obs studio
    FZF_DEFAULT_COMMAND = "rg --files --hidden";
  };

  home.packages = with pkgs; [
    # utils
    bat
    btop
    fastfetch
    fd
    feh
    fzf
    openrgb
    pavucontrol
    ripgrep
    unzip
    usbutils
    xdg-utils

    # terminals
    alacritty
    wezterm

    # editor
    helix

    # browse
    firefox

    # comms
    (discord.override { nss = pkgs.nss_latest; })
    signal-desktop

    # fonts
    font-awesome
    iosevka
    noto-fonts
    noto-fonts-emoji
    powerline-fonts
    powerline-symbols

    # sound
    easyeffects

    # video
    obs-studio

    # misc
    qbittorrent
  ];

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
