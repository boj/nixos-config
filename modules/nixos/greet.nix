{ config, lib, pkgs, username, ... }:
let
  cfg = config.my.greet;
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
in {
  options.my.greet.enable = lib.mkEnableOption "tuigreet";
  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # No --cmd: tuigreet shows the wayland-sessions picker so the user
          # can switch between Hyprland and Niri. --remember-user-session
          # makes the last choice sticky.
          command = "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time";
          user = "greeter";
        };
      };
    };
  };
}
