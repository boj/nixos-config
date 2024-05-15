{
  wayland.windowManager.hyprland.settings = {
    workspace = [
      "1, persistent:true, monitor:DP-1"
      "2, persistent:true, monitor:DP-1"
      "3, persistent:true, monitor:DP-1"
      "4, persistent:true, monitor:DP-1"
      "5, persistent:true, monitor:DP-1"
      "6, persistent:true, monitor:DP-3"
      "7, persistent:true, monitor:DP-3"
      "8, persistent:true, monitor:DP-3"
      "9, persistent:true, monitor:DP-3"
      "10, persistent:true, monitor:DP-3"
    ];
    windowrulev2 = [
      "workspace 6 silent,title:^(.*Discord)$"
      "stayfocused,class:(steam),title:(^$)"
    ];
  };
}
