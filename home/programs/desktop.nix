{pkgs, ...}: {
  home.packages = with pkgs; [
    # utils
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
    obs-studio

    # misc
    qbittorrent

    # art / dev
    blender
    godot_4
  ];

  home.sessionVariables = {
    BROWSER = "firefox";
    QT_QPA_PLATFORM = "xcb"; # obs studio
  };
}
