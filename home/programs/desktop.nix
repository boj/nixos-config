{pkgs, ...}: {
  home.packages = with pkgs; [
    # utils
    # cava
    feh
    openrgb
    pavucontrol

    # browse
    firefox

    # comms
    (discord.override {nss = pkgs.nss_latest;})
    signal-desktop

    # sound
    easyeffects

    # video
    # obs-studio

    # misc
    obsidian
    qbittorrent

    # art / dev
    blender
    godot_4

    # 3d printing
    bambu-studio
  ];

  home.sessionVariables = {
    BROWSER = "firefox";
    QT_QPA_PLATFORM = "xcb"; # obs studio
  };
}
