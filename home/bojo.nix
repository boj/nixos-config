{
  imports = [
    ./common
    ./features
  ];

  my.development.enable = true;
  my.development.ai.enable = true;
  # my.programs.desktop.enable = true;
  my.programs.streamdeck.enable = true;
  my.programs.work.enable = true;
  my.services.easyeffects.enable = true;
  my.terminals.ghostty.enable = true;

  my.terminals.wezterm.enable = true;
  my.terminals.zellij.enable = true;
  my.wayland.enable = true;
  # Noctalia shell + Umbriel compositor replace the Hyprland session and the
  # slate bar. Roll back by enabling hyprland + slate and disabling these.
  my.wayland.hyprland.enable = false;
  my.wayland.slate.enable = false;
  my.wayland.umbriel.enable = true;
  my.wayland.noctalia.enable = true;
}
