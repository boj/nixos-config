{
  config,
  lib,
  ...
}: let
  cfg = config.my.wayland.hyprland;
in {
  config = lib.mkIf (cfg.enable && cfg.idleTimeout != null) {
    xdg.configFile."hypr/hypridle.conf".text = ''
      general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
      }

      listener {
        timeout = ${toString cfg.idleTimeout}
        on-timeout = hyprlock
        on-resume = hyprctl dispatch dpms on
      }

      listener {
        timeout = ${toString (if cfg.dpmsTimeout != null then cfg.dpmsTimeout else cfg.idleTimeout + 300)}
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
      }
    '';

    wayland.windowManager.hyprland.settings.exec-once = ["hypridle"];
  };
}
