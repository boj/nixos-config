{
  wayland.windowManager.hyprland.settings = {
    workspace = [
      "w[tv1], gapsout:10, gapsin:10"
      "f[1], gapsout:10, gapsin:10"
      "bordersize 10, floating:10, onworkspace:w[tv1]"
      "rounding 10, floating:10, onworkspace:w[tv1]"
      "bordersize 10, floating:10, onworkspace:f[1]"
      "rounding 10, floating:10, onworkspace:f[1]"
    ];
    windowrulev2 = [
      "workspace 6 silent,title:^(.*Discord)$"
      # "stayfocused,class:(steam),title:(^$)"
    ];
  };
}
