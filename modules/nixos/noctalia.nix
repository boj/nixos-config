{ config, lib, inputs, ... }:
let cfg = config.my.noctalia; in {
  # System-level integration for the Noctalia shell. The shell itself runs as a
  # home-manager process (autostarted by Umbriel); this module installs the
  # package system-wide and opts into the services Noctalia's v5 widgets expect
  # (NetworkManager, Bluetooth, UPower, power profiles). Everything it enables
  # uses mkDefault, so it never clobbers host-specific networking/power config.
  imports = [inputs.noctalia.nixosModules.default];

  options.my.noctalia.enable = lib.mkEnableOption "Noctalia desktop shell";

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };
  };
}
