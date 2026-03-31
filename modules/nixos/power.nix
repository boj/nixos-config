{
  config,
  lib,
  ...
}: {
  options.my.power.enable = lib.mkEnableOption "power management (auto-cpufreq + powertop)";

  config = lib.mkIf config.my.power.enable {
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
  };
}
