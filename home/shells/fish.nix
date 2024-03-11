{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fastfetch
    '';
    #loginShellInit = ''
    #  if test -z $DISPLAY; and test (tty) = "/dev/tty1"
    #    dbus-run-session Hyprland
    #  end
    #'';
  };
}
