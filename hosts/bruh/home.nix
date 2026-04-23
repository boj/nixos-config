{
  my.gpu = "amd";
  my.programs.gaming.enable = true;
  my.wayland.weather.latitude = 61.32;
  my.wayland.weather.longitude = -149.39;
  my.wayland.hyprland.useFunctionKeys = true;
  my.wayland.hyprland.monitors = [
    "DP-1,1920x1080@240,0x0,1"
    "DP-3,1920x1080@240,1920x0,1"
  ];
  my.wayland.hyprland.execOnce = [
    "[workspace 1 silent] chromium"
    "[workspace 6 silent] discord"
  ];
}
