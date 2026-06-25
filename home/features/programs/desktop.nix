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
      (chromium.override {
        enableWideVine = true;
        proprietaryCodecs = true;
      })

      # comms
      vesktop
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
