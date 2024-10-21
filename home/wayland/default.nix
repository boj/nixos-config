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

  colorScheme = nix-colors.colorSchemes.nord;

  home.packages = with pkgs; [
    # wayland
    grim
    libnotify
    slurp
    swayidle
    waybar
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
