{ config, lib, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fastfetch
    '';
    # Only auto-exec Hyprland from the login shell when the TTY-autologin
    # Hyprland session is active. Under the Noctalia greeter / Umbriel the
    # session is launched by greetd, so this must not run.
    loginShellInit = lib.optionalString (config.my.wayland.hyprland.enable or false) ''
      start-hyprland
    '';
    shellAliases = {
      ls = "eza";
    };
  };
}
