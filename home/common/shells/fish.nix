{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      if test (tty) = /dev/tty1
        exec start-hyprland
      end
      fastfetch
    '';
    shellAliases = {
      ls = "eza";
    };
  };
}
