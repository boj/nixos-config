{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.wayland.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      windowrule = [
        "match:class ^(com\\.gabm\\.satty)$, float on"
        "match:class ^(com\\.gabm\\.satty)$, size (monitor_w*0.75) (monitor_h*0.75)"
        "match:class ^(com\\.gabm\\.satty)$, center on"
      ];
      workspace = [
        "w[tv1], gapsout:10, gapsin:10"
        "f[1], gapsout:10, gapsin:10"
        "bordersize 10, floating:10, onworkspace:w[tv1]"
        "rounding 10, floating:10, onworkspace:w[tv1]"
        "bordersize 10, floating:10, onworkspace:f[1]"
        "rounding 10, floating:10, onworkspace:f[1]"
      ];
    };
  };
}
