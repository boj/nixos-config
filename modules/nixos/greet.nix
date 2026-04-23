{ config, lib, pkgs, username, ... }:
let
  cfg = config.my.greet;
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  session = "start-hyprland";
in {
  options.my.greet.enable = lib.mkEnableOption "tuigreet";
  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = session;
          user = username;
        };
        default_session = {
          command = "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --cmd ${session}";
          user = username;
        };
      };
    };
  };
}
