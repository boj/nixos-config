{
  config,
  lib,
  ...
}:
let
  cfg = config.my.power;
in {
  options.my.power.enable = lib.mkEnableOption "power management (auto-cpufreq + powertop)";

  config = lib.mkIf cfg.enable {
    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

    powerManagement.powertop.enable = true;

    # UPower provides battery/AC status over D-Bus. Needed by the Slate
    # bar's Battery widget (Quickshell.Services.UPower) and generally
    # useful on any host with a battery.
    services.upower.enable = true;

    # Disable USB autosuspend (powertop enables it by default), so USB
    # peripherals don't sleep and drop input/become unresponsive.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    '';
  };
}
