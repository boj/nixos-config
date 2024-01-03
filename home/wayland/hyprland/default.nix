{pkgs, ...}: {
  imports = [
    ./binds.nix
    ./rules.nix
    ./settings.nix
  ];

  home.packages = with pkgs; [
    hyprpaper
  ];

  wayland.windowManager.hyprland = {
    enable = true;
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };
}
