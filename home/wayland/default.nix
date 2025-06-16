{
  pkgs,
  nix-colors,
  ...
}: {
  imports = [
    # ./ags.nix
    ./dunst.nix
    ./waybar.nix
    ./wofi.nix
    ./gtk.nix
    ./qt.nix
    nix-colors.homeManagerModules.default
  ];

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  home.packages = with pkgs; [
    # wayland
    grim
    libnotify
    mpvpaper
    slurp
    swww
    swayidle
    waybar
    waypaper
    wl-clipboard
    wofi
    ydotool
  ];

  home.sessionVariables = {
    # SDL_VIDEODRIVER = "wayland";
    WLR_RENDERER = "vulkan";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1";
    NIXOS_XDG_OPEN_USE_PORTAL = "1";
  };
}
