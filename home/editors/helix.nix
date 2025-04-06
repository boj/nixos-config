{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
    nil
    zig
    zls
  ];

  programs.helix = {
    enable = true;
    package = inputs.helix.packages.${pkgs.system}.helix;
    defaultEditor = true;
    settings = {
      theme = "ao-trans";
    };
    themes = {
      nord-trans = {
        inherits = "nord";
        "ui.background" = "none";
      };
      ao-trans = {
        inherits = "ao";
        "ui.background" = "none";
      };
    };
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "${pkgs.alejandra}/bin/alejandra";
          };
        }
        {
          name = "markdown";
          soft-wrap.enable = true;
        }
      ];
      language-server.fsharp = {
        command = "${pkgs.fsautocomplete}/bin/fsautocomplete";
      };
      language-server.zig = {
        command = "${pkgs.zls}/bin/zls";
      };
    };
  };

  home.sessionVariables = {
    VISUAL = "hx";
  };
}
