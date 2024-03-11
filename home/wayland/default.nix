{pkgs, ...}: {
  imports = [
    ./dunst.nix
    ./waybar.nix
    ./wofi.nix
    ./gtk.nix
    ./qt.nix
  ];

  home.packages = with pkgs; [
    # wayland
    grim
    libnotify
    slurp
    swayidle
    waybar
    wl-clipboard
    wofi

    # fonts
    font-awesome
    iosevka
    noto-fonts
    noto-fonts-emoji
    powerline-fonts
    powerline-symbols
  ];

  home.sessionVariables = {
    # SDL_VIDEODRIVER = "wayland";
    WLR_RENDERER = "vulkan";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1";
    NIXOS_XDG_OPEN_USE_PORTAL = "1";
  };
}
