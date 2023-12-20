{ pkgs, config, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "ayu_light";
    };
  };
}
