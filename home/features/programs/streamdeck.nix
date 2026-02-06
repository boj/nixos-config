{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.streamdeck;
in {
  options.my.programs.streamdeck.enable = lib.mkEnableOption "Stream Deck";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      deckmaster
      xdotool
    ];
  };
}
