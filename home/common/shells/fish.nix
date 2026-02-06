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
  };
}
