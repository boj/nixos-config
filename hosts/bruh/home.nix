{
  my.programs.gaming.enable = true;
  my.services.cloudflare-ddns = {
    enable = true;
    record = "enshrouded.brojo.io";
    zone = "brojo.io";
    interval = "*:0/15";
  };
  my.wayland.weather.latitude = 61.32;
  my.wayland.weather.longitude = -149.39;
  my.wayland.hyprland.useFunctionKeys = true;
  my.wayland.hyprland.monitors = [
    "DP-1,1920x1080@240,0x0,1"
    "DP-3,1920x1080@240,1920x0,1"
  ];
  my.wayland.hyprland.workspaces = [
    "1,monitor:DP-1,default:true"
    "2,monitor:DP-1"
    "3,monitor:DP-1"
    "4,monitor:DP-1"
    "5,monitor:DP-1"
    "6,monitor:DP-3,default:true"
    "7,monitor:DP-3"
    "8,monitor:DP-3"
    "9,monitor:DP-3"
    "10,monitor:DP-3"
  ];
  my.wayland.hyprland.waybarPersistentWorkspaces = {
    "DP-1" = [1 2 3 4 5];
    "DP-3" = [6 7 8 9 10];
  };
  my.wayland.hyprland.execOnce = [
    "[workspace 1 silent] chromium"
    "[workspace 6 silent] vesktop"
  ];
}
