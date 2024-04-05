{pkgs, ...}: {
  home.packages = with pkgs; [
    deckmaster
    xdotool
  ];
}
