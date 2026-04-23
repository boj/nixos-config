{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.desktop;
in {
  options.my.programs.desktop.enable = lib.mkEnableOption "desktop programs";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # utils
      # cava
      feh
      openrgb
      pavucontrol

      # browse
      chromium

      # comms
      (discord.override {nss = pkgs.nss_latest;})
      signal-desktop

      # sound
      easyeffects

      # music
      spotify

      # video
      obs-studio

      # misc
      obsidian
      qbittorrent

      # 3d printing
      # bambu-studio
    ];

    home.sessionVariables = {
      BROWSER = "firefox";
      QT_QPA_PLATFORM = "xcb"; # obs studio
    };
  };
}
