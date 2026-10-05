{ config, lib, inputs, username, ... }:
let cfg = config.my.noctalia-greeter; in {
  # greetd greeter styled to match Noctalia. Replaces the TTY autologin as the
  # login path. The flake module pulls in greetd and wires default_session to
  # noctalia-greeter-session; we only pick the default session/user and a theme.
  imports = [inputs.noctalia-greeter.nixosModules.default];

  options.my.noctalia-greeter.enable = lib.mkEnableOption "Noctalia greeter (greetd)";

  config = lib.mkIf cfg.enable {
    services.displayManager.noctalia-greeter = {
      enable = true;
      # Allow the primary user to push appearance-only sync without a password.
      passwordless-sync-users = [username];
      settings = {
        session.default = "Umbriel";
        user.default = username;
        appearance = {
          scheme = "Catppuccin";
          theme_mode = "dark";
        };
      };
    };
  };
}
