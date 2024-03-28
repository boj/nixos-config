{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fastfetch
    '';
    shellAliases = {
      ls = "eza";
    };
    #loginShellInit = ''
    #  if test -z $DISPLAY; and test (tty) = "/dev/tty1"
    #    dbus-run-session Hyprland
    #  end
    #'';
  };
}
