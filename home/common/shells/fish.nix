{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fastfetch
    '';
    loginShellInit = ''
      start-hyprland
    '';
    shellAliases = {
      ls = "eza";
    };
  };
}
