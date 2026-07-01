{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.my.nixIndex;
in {
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  options.my.nixIndex.enable = lib.mkEnableOption "nix-index + comma (`,`) integration";

  config = lib.mkIf cfg.enable {
    # Replaces the (heavy, network-fetching) command-not-found with a local index
    # shipped by the flake, and enables `,` (comma) to run any package ad-hoc:
    #   , ripgrep --help
    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enable = true;

    # command-not-found relies on channels; disable it in favor of nix-index.
    programs.command-not-found.enable = false;
  };
}
