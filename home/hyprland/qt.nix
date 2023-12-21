{ pkgs, ...}:

{
  qt = {
    enable = true;
    platformTheme = "gnome";
    style.name = "adwaita-dark";
  };	
}
