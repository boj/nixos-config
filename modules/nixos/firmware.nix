{
  config,
  lib,
  ...
}: let
  cfg = config.my.firmware;
in {
  options.my.firmware.enable =
    lib.mkEnableOption "firmware updates via fwupd/LVFS";

  config = lib.mkIf cfg.enable {
    # fwupd manages device firmware (UEFI/BIOS, NVMe, Thunderbolt, etc.) via
    # the Linux Vendor Firmware Service (LVFS). Enabling this also puts the
    # `fwupdmgr` CLI on PATH. Typical workflow:
    #   sudo fwupdmgr get-devices        # what fwupd can see (BIOS = "System Firmware")
    #   sudo fwupdmgr refresh --force    # pull latest LVFS metadata
    #   sudo fwupdmgr get-updates        # list available updates
    #   sudo fwupdmgr update             # apply (UEFI capsules flash on next reboot)
    #
    # NOTE: this only finds updates the OEM actually publishes to LVFS. If
    # `get-updates` reports nothing, the vendor ships firmware out-of-band
    # (Windows tool or a BIOS-menu/USB capsule) and fwupd can't help.
    services.fwupd.enable = true;
  };
}
