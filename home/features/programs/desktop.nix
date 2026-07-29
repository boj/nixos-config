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
      # spotify

      # video
      davinci-resolve
      obs-studio

      # misc
      obsidian
      qbittorrent

      # 3d printing
      # bambu-studio
    ]
    # On hybrid NVIDIA laptops, DaVinci Resolve needs PRIME offload env vars
    # (so its OpenGL context lands on the NVIDIA GPU alongside CUDA) and must
    # have ambient capabilities stripped (Hyprland propagates CAP_SYS_NICE,
    # which trips bwrap's setuid check inside davinci-resolve's FHS wrapper).
    # `hiPrio` ensures this wrapper wins over the plain davinci-resolve above
    # in the user profile's bin directory.
    ++ lib.optional (config.my.gpu == "nvidia") (lib.hiPrio (pkgs.writeShellScriptBin "davinci-resolve" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec ${pkgs.util-linux}/bin/setpriv --ambient-caps=-all --inh-caps=-all \
        ${pkgs.davinci-resolve}/bin/davinci-resolve "$@"
    ''));

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
