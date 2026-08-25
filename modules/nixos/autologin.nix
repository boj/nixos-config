{ config, lib, username, ... }:
let cfg = config.my.autologin; in {
  options.my.autologin.enable =
    lib.mkEnableOption "TTY autologin that boots directly into Hyprland";

  config = lib.mkIf cfg.enable {
    # Autologin the primary user on tty1. The user's login shell (fish)
    # execs Hyprland via UWSM from its loginShellInit, so no display
    # manager / greeter is involved.
    services.getty.autologinUser = username;
  };
}
