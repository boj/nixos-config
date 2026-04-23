{
  my.gpu = "nvidia";
  my.wayland.weather.latitude = 61.60;
  my.wayland.weather.longitude = -149.11;
  my.wayland.battery.enable = true;
  my.wayland.hyprland.monitors = [
    "desc:Dell Inc. DELL P2417H KH0NG77E1VVB,1920x1080@60,0x0,1"
    "desc:Dell Inc. DELL P2417H KH0NG7873KDI,1920x1080@60,1920x0,1"
    "desc:AU Optronics 0x97A2,3840x2160@120,0x1080,2"
  ];
  my.wayland.hyprland.workspaces = [
    "1, monitor:desc:Dell Inc. DELL P2417H KH0NG77E1VVB, default:true"
    "2, monitor:desc:Dell Inc. DELL P2417H KH0NG77E1VVB"
    "3, monitor:desc:Dell Inc. DELL P2417H KH0NG77E1VVB"
    "4, monitor:desc:Dell Inc. DELL P2417H KH0NG7873KDI, default:true"
    "5, monitor:desc:Dell Inc. DELL P2417H KH0NG7873KDI"
    "6, monitor:desc:Dell Inc. DELL P2417H KH0NG7873KDI"
    "7, monitor:desc:AU Optronics 0x97A2, default:true"
    "8, monitor:desc:AU Optronics 0x97A2"
    "9, monitor:desc:AU Optronics 0x97A2"
  ];
  my.wayland.hyprland.waybarPersistentWorkspaces = {
    "DP-8" = [1 2 3];
    "DP-7" = [4 5 6];
    "eDP-1" = [7 8 9];
  };
  my.wayland.kanshi = {
    enable = true;
    profiles = {
      docked = {
        outputs = [
          {
            criteria = "Dell Inc. DELL P2417H KH0NG77E1VVB";
            mode = "1920x1080@60";
            position = "0,0";
          }
          {
            criteria = "Dell Inc. DELL P2417H KH0NG7873KDI";
            mode = "1920x1080@60";
            position = "1920,0";
          }
          {
            criteria = "eDP-1";
            mode = "3840x2160@120";
            position = "0,1080";
          }
        ];
        exec = [
          "move-workspaces 1:desc:Dell_Inc._DELL_P2417H_KH0NG77E1VVB 2:desc:Dell_Inc._DELL_P2417H_KH0NG77E1VVB 3:desc:Dell_Inc._DELL_P2417H_KH0NG77E1VVB 4:desc:Dell_Inc._DELL_P2417H_KH0NG7873KDI 5:desc:Dell_Inc._DELL_P2417H_KH0NG7873KDI 6:desc:Dell_Inc._DELL_P2417H_KH0NG7873KDI 7:eDP-1 8:eDP-1 9:eDP-1"
          ''waybar-set-workspaces '{"DP-8":[1,2,3],"DP-7":[4,5,6],"eDP-1":[7,8,9]}' ''
          "restart-waybar"
        ];
      };
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            mode = "3840x2160@60";
            position = "0,0";
          }
        ];
        exec = [
          "move-workspaces 1:eDP-1 2:eDP-1 3:eDP-1 4:eDP-1 5:eDP-1 6:eDP-1 7:eDP-1 8:eDP-1 9:eDP-1"
          ''waybar-set-workspaces '{"*":[1,2,3,4,5,6,7,8,9]}' ''
          "restart-waybar"
        ];
      };
    };
  };
  my.wayland.hyprland.execOnce = [
    "hyprlock"
  ];
  my.wayland.hyprland.idleTimeout = 1200;
}
