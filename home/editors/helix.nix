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
      theme = "nord";
    };
    languages = {
      language = [{
        name = "nix";
        auto-format = true;
        formatter = {
          command = "${pkgs.alejandra}/bin/alejandra";
        };
      }];
    };
  };

  home.sessionVariables = {
    VISUAL = "hx";
  };
}
