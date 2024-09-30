{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
    nil
  ];

  programs.helix = {
    enable = true;
    package = inputs.helix.packages.${pkgs.system}.helix;
    defaultEditor = true;
    settings = {
      theme = "nord-trans";
    };
    themes = {
      nord-trans = {
        inherits = "nord";
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
      ];
      language-server.fsharp = {
        command = "${pkgs.fsautocomplete}/bin/fsautocomplete";
      };
    };
  };

  home.sessionVariables = {
    VISUAL = "hx";
  };
}
