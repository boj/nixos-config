{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.development;
in {
  imports = [
    ./ai.nix
  ];

  options.my.development.enable = lib.mkEnableOption "development tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # support
      flyctl
      gcc
      gh

      # frontend
      pnpm
      nodejs

      # rust
      cargo
      rust-analyzer
      rustc

      # postgres / migrations
      sqitchPg
      postgresql
    ];
  };
}
