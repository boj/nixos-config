{ config, pkgs, ... }:

{
  imports = [
    ./gtk.nix
    ./binds.nix
    ./settings.nix  
  ];

  home.packages = with pkgs; [
    dunst
    grim
    slurp
    swayidle
    waybar
    wl-clipboard
    wofi

    hyprpaper
  ];

  wayland.windowManager.hyprland = {
		enable = true;
  };
}
