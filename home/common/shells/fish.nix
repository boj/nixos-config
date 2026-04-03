{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      # Apply caelestia color scheme to new terminal sessions
      if test -f ~/.local/state/caelestia/sequences.txt
        cat ~/.local/state/caelestia/sequences.txt
      end
      fastfetch
    '';
    shellAliases = {
      ls = "eza";
    };
  };
}
