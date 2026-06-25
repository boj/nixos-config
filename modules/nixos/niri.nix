{ config, lib, pkgs, inputs, ... }:
let cfg = config.my.niri; in {
  imports = [inputs.niri.nixosModules.niri];

  options.my.niri.enable = lib.mkEnableOption "Niri scrollable-tiling compositor";

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [inputs.niri.overlays.niri];

    programs.niri = {
      enable = true;
      # niri-unstable is required for the xwayland-satellite integration option
      # (programs.niri.settings.xwayland-satellite.*), which is what gets Steam
      # and X11 games working under niri. Stable niri has no XWayland at all.
      package = pkgs.niri-unstable;
    };

    # Screencasting under niri uses xdg-desktop-portal-gnome's ScreenCast
    # backend (which speaks the same PipeWire/portal protocol niri implements).
    # The wlr portal does NOT work with niri.
    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-gnome
      xwayland-satellite-unstable
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}

