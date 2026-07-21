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
      davinci-resolve
      obs-studio

      # misc
      obsidian
      qbittorrent

      # 3d printing
      # bambu-studio
    ];

    home.sessionVariables = {
      BROWSER = "chromium";
      QT_QPA_PLATFORM = "xcb"; # obs studio
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = let
        chromium = ["chromium-browser.desktop"];
      in {
        "text/html" = chromium;
        "x-scheme-handler/http" = chromium;
        "x-scheme-handler/https" = chromium;
        "x-scheme-handler/about" = chromium;
        "x-scheme-handler/unknown" = chromium;
        "application/xhtml+xml" = chromium;
      };
    };
  };
}
