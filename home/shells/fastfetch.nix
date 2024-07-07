{
  programs.fastfetch = {
    enable = true;
    settings = {
      display = {
        separator = "    ";
      };
      modules = [
        {
          type = "custom";
          format = "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓";
        }
        {
          type = "os";
          key = "  ";
          keyColor = "blue";
        }
        {
          type = "kernel";
          key = "  ";
          keyColor = "white";
        }
        {
          type = "packages";
          key = "  󰮯";
          keyColor = "yellow";
        }
        {
          type = "wm";
          key = "  󰨇";
          keyColor = "blue";
        }
        {
          type = "terminal";
          key = "  ";
          keyColor = "magenta";
        }
        {
          type = "shell";
          key = "  ";
          keyColor = "yellow";
        }
        {
          type = "custom";
          format = "┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫";
        }
        {
          type = "host";
          key = "  ";
          keyColor = "bright_blue";
        }
        {
          type = "cpu";
          key = "  ";
          keyColor = "bright_green";
        }
        {
          type = "gpu";
          key = "  󱤓";
          keyColor = "red";
        }
        {
          type = "memory";
          key = "  󰍛";
          keyColor = "bright_yellow";
        }
        {
          type = "disk";
          key = "  ";
          keyColor = "bright_cyan";
        }
        {
          type = "custom";
          format = "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛";
        }
      ];
    };
  };
}
