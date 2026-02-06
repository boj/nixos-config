{ config, lib, pkgs, inputs, ... }:
let cfg = config.my.rust; in {
  options.my.rust.enable = lib.mkEnableOption "Rust toolchain via overlay";
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [inputs.rust-overlay.overlays.default];
    environment.systemPackages = [pkgs.rust-bin.stable.latest.default];
  };
}
