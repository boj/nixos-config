{pkgs, ...}: {
  home.packages = with pkgs; [
    wezterm
  ];

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}

      if wezterm.config_builder then
        config = wezterm.config_builder()
      end

      config.color_scheme = 'nord'
      config.enable_tab_bar = false
      config.font_size = 10.5
      config.text_background_opacity = 0.5
      config.window_background_opacity = 0.5
      config.window_padding = {
        left = 30,
        right = 30,
        top = 20,
        bottom = 20,
      }

      config.enable_wayland = false

      return config
    '';
  };
}
