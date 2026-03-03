{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.terminals.zellij;
in {
  options.my.terminals.zellij.enable = lib.mkEnableOption "Zellij terminal multiplexer";

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
    };
  };
}
