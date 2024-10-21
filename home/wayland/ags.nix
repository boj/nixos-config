{pkgs, ...}: {
  home.packages = with pkgs; [
    ags
    bun
    hyprpanel
  ];
}
