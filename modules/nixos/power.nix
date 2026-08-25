{
  config,
  lib,
  ...
}:
let
  cfg = config.my.power;
in {
  options.my.power.enable = lib.mkEnableOption "power management (sane defaults, performance-biased)";

  config = lib.mkIf cfg.enable {
    # NOTE: auto-cpufreq was removed. On this host's Intel Core Ultra 7 255H
    # (Arrow Lake-H, intel_pstate driver) auto-cpufreq misbehaved: it
    # busy-looped (~10% of a core) and left the CPU in a broken throttled
    # state (turbo disabled via intel_pstate/no_turbo, cores pinned at their
    # 400MHz floor), tanking system performance. intel_pstate manages
    # frequency scaling natively and correctly, so we let it do its job.

    # NOTE: powertop --auto-tune was removed. It flipped the NVMe controller
    # to runtime autosuspend (power/control=auto), and with the kernel's
    # default 100ms APST budget the drive dropped into deep power states
    # whenever idle. Every cold read then paid a multi-millisecond wake
    # penalty (~10ms/read observed, drive idling at 27C), making apps load
    # slowly. Disabling APST keeps the NVMe responsive.
    boot.kernelParams = ["nvme_core.default_ps_max_latency_us=0"];

    # UPower provides battery/AC status over D-Bus. Needed by the Slate
    # bar's Battery widget (Quickshell.Services.UPower) and generally
    # useful on any host with a battery.
    services.upower.enable = true;

    # Force USB peripherals to never autosuspend, so they don't sleep and
    # drop input / become unresponsive. Defensive: with powertop removed
    # nothing enables USB autosuspend by default, but this guarantees it.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    '';
  };
}
