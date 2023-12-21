{pkgs, ...}: {
  imports = [
    ./hyprland
    ./waybar.nix
    ./wofi.nix
    ./gtk.nix
    ./qt.nix
    ./eww.nix
  ];

  home.packages = with pkgs; [
    # wayland
    dunst
    grim
    slurp
    swayidle
    waybar
    wl-clipboard
    wofi

    # utils
    feh
    openrgb
    pavucontrol

    # browse
    firefox

    # comms
    (discord.override {nss = pkgs.nss_latest;})
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

  home.sessionVariables = {
    BROWSER = "firefox";
    SDL_VIDEODRIVER = "wayland";
    WLR_RENDERER = "vulkan";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1";
    NIXOS_XDG_OPEN_USE_PORTAL = "1";
    QT_QPA_PLATFORM = "xcb"; # obs studio
  };
}
