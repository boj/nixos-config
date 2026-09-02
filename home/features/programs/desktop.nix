{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.desktop;
  # DaVinci Resolve Studio is licensed per-machine, so only hosts with a valid
  # license get the Studio edition; everything else falls back to the free one.
  davinciPkg =
    if cfg.davinciEdition == "studio"
    then pkgs.davinci-resolve-studio
    else pkgs.davinci-resolve;
  davinciBin = davinciPkg.meta.mainProgram;
  # DaVinci Resolve must have ambient capabilities stripped on every host:
  # Hyprland propagates CAP_SYS_NICE, which trips bwrap's setuid check inside
  # davinci-resolve's FHS wrapper ("Unexpected capabilities but not setuid").
  # On hybrid NVIDIA laptops it additionally needs PRIME offload env vars so
  # its OpenGL context lands on the NVIDIA GPU alongside CUDA.
  davinciWrapper = pkgs.writeShellScriptBin davinciBin ''
    ${lib.optionalString (config.my.gpu == "nvidia") ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
    ''}
    exec ${pkgs.util-linux}/bin/setpriv --ambient-caps=-all --inh-caps=-all \
      ${davinciPkg}/bin/${davinciBin} "$@"
  '';
in {
  options.my.programs.desktop = {
    enable = lib.mkEnableOption "desktop programs";
    davinciEdition = lib.mkOption {
      type = lib.types.enum ["studio" "free"];
      default = "free";
      description = "Which DaVinci Resolve edition to install (Studio is licensed per-machine).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [
        # utils
        # cava
        feh
        openrgb
        pavucontrol

        # browse
        (chromium.override {
          enableWideVine = true;
          proprietaryCodecs = true;
          # No Secret Service/keyring runs in this passwordless-autologin
          # Hyprland session, so Chromium's portal key store fails to init
          # (os_crypt.portal.prev_init_success=false) and re-derives an
          # unstable key each launch, wiping cookies + the 1Password
          # extension session. Pin the stable built-in "basic" key store so
          # sessions persist across restarts.
          commandLineArgs = "--password-store=basic";
        })

        # comms
        vesktop
        signal-desktop

        # sound
        easyeffects

        # music
        # spotify

        # video
        davinciPkg
        obs-studio

        # misc
        obsidian
        qbittorrent

        # 3d printing
        # bambu-studio
      ]
      # `hiPrio` ensures this wrapper wins over the plain davinciPkg binary
      # above in the user profile's bin directory.
      ++ [(lib.hiPrio davinciWrapper)];

    home.sessionVariables = {
      BROWSER = "chromium";
      QT_QPA_PLATFORM = "xcb"; # obs studio
    };

    # Override the packaged DaVinci Resolve .desktop entry so an app-menu launch
    # goes through the capability-stripping wrapper by absolute path, instead of
    # relying on the bare `Exec=<mainProgram>` PATH lookup resolving to it.
    xdg.desktopEntries.${davinciBin} = {
      name =
        if cfg.davinciEdition == "studio"
        then "Davinci Resolve Studio"
        else "Davinci Resolve";
      genericName = "Video Editor";
      comment = "Professional video editing, color, effects and audio post-processing";
      exec = "${davinciWrapper}/bin/${davinciBin} %U";
      icon = davinciBin;
      startupNotify = true;
      categories = ["AudioVideo" "AudioVideoEditing" "Video" "Graphics"];
      settings.StartupWMClass = "resolve";
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
