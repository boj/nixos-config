{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod3";
      terminal = "wezterm";
    };
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
  };
}
