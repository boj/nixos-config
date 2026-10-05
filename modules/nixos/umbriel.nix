{ config, lib, inputs, ... }:
let cfg = config.my.umbriel; in {
  # The flake's NixOS module wires up the compositor package, the Wayland
  # session (.desktop entry for greetd), graphics, and the
  # xdg-desktop-portal-umbriel backend.
  imports = [inputs.umbriel.nixosModules.default];

  options.my.umbriel.enable = lib.mkEnableOption "Umbriel Wayland compositor";

  config = lib.mkIf cfg.enable {
    programs.umbriel.enable = true;
  };
}
