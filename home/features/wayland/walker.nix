{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.wayland.walker;
in {
  options.my.wayland.walker = {
    enable = lib.mkEnableOption "walker application launcher";
    replaceWofi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When true, `my.wayland.launcher` resolves to `walker`, so keybinds
        can call `''${config.my.wayland.launcher} --show=drun` in a
        launcher-agnostic way. Both walker and wofi are always installed
        when their respective modules are enabled.
      '';
    };
  };

  # Expose a single "launcher" command so binds don't have to hardcode walker/wofi.
  options.my.wayland.launcher = lib.mkOption {
    type = lib.types.str;
    default = "wofi";
    description = "Launcher binary to invoke from keybinds.";
    internal = true;
  };

  config = lib.mkIf (config.my.wayland.enable && cfg.enable) (lib.mkMerge [
    {
      home.packages = with pkgs; [walker];

      # walker reads TOML from XDG_CONFIG_HOME/walker/config.toml. Keep it minimal;
      # defaults are sensible. Add a modules list to enable calc, clipboard, runner.
      xdg.configFile."walker/config.toml".text = ''
        app_launch_prefix = ""
        terminal_title_flag = ""
        locale = ""
        close_when_open = true
        theme = "default"
        monitor = ""
        hotreload_theme = false

        [keys]
        accept_typeahead = ["tab"]
        trigger_labels = "lalt"
        next = ["down"]
        prev = ["up"]
        close = ["esc"]

        [list]
        max_entries = 50
        show_initial_entries = true
        single_click = true

        [search]
        placeholder = "Search"
        delay = 0

        [builtins.applications]
        weight = 5
        placeholder = "Applications"
        prioritize_new = true
        hide_actions_with_empty_query = true

        [builtins.calc]
        weight = 5
        placeholder = "Calculator"
        min_chars = 3

        [builtins.clipboard]
        weight = 5
        placeholder = "Clipboard"
        max_entries = 100
        avoid_line_breaks = true

        [builtins.commands]
        weight = 5
        placeholder = "Commands"

        [builtins.runner]
        weight = 5
        placeholder = "Runner"
        use_history = true

        [builtins.symbols]
        weight = 5
        placeholder = "Symbols"
        after_copy = "close"

        [builtins.ssh]
        weight = 5
        placeholder = "SSH"

        [builtins.finder]
        weight = 5
        placeholder = "Finder"
        use_fd = true
        fd_flags = "--ignore-file ~/.config/walker/fdignore --type f"
      '';
    }

    (lib.mkIf cfg.replaceWofi {
      my.wayland.launcher = lib.mkForce "walker";
    })
  ]);
}
