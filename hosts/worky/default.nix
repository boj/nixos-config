{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../lib/defaultProfile.nix
  ];

  # Host-specific
  my.wifi.enable = true;
  my.power.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "worky";
  programs.dconf.enable = true;

  # Intel Arc iGPU (Arrow Lake-H, 8086:7D51) driven by i915/xe. This laptop
  # has no discrete GPU, so there is no PRIME offload — the whole desktop
  # runs on Intel. GPU package wiring lives in modules/nixos/gpu.nix
  # (gated on my.gpu == "intel", set in flake.nix).

  # HARDWARE QUIRK — NVMe behind Intel VMD has broken interrupt delivery.
  # The onboard SK hynix PC811 sits behind Intel VMD (controller 8086:7d0b;
  # BIOS storage mode = "RST"/"VMD"; ACPI tables RstVmdE/RstVmdV). The VMD
  # bridge remaps the drive's MSI-X through its own vector pool and the handoff
  # is broken — the completion interrupt is raised before the DMA'd data is
  # visible, so the kernel never sees it (Intel erratum, MTL016 class):
  #
  #   nvme 10000:e1:00.0: PCI INT A: not connected
  #   pcieport 10000:e0:06.1: can't derive routing for PCI INT A/B: no GSI
  #   nvme nvme0: I/O tag ... timeout, completion polled
  #
  # Every I/O then waits the full nvme_core.io_timeout and only completes when
  # the driver gives up and polls the queue. This makes ALL disk reads
  # pathologically slow — app launches, nix builds, and boot itself (the tty1
  # "hang" before hyprlock is systemd reading off the stalled drive). The drive
  # is healthy (SMART: 0 media errors, 0% used); only the IRQ is lost.
  #
  # FIX (applied): remove VMD from the data path by switching the BIOS storage
  # controller from RST/RAID to AHCI. This firmware lacks a visible BIOS menu
  # toggle, but the Dell HII setting is still writable at runtime via the
  # dell-wmi-sysman driver — no admin password was set on this box:
  #
  #   echo Ahci | sudo tee \
  #     /sys/class/firmware-attributes/dell-wmi-sysman/attributes/EmbSataRaid/current_value
  #
  # The change is stored in firmware and takes effect on the next reboot. No
  # reinstall is needed — all mounts are by-UUID and the initrd carries `vmd`
  # and `nvme`. After AHCI, the drive enumerates on PCI domain 0000 with normal
  # per-queue MSI-X and the timeouts disappear.
  #
  # WHAT DIDN'T WORK (measured on identical 8086:7d0b hardware, kept here so we
  # don't chase them again): newer/older kernels (the bug is kernel-agnostic;
  # the MSI-remap-bypass flag is cleared for laptop VMD silicon and no module
  # param exists), BIOS/SSD firmware updates, and disabling ASPM/APST (the
  # existing nvme_core.default_ps_max_latency_us=0 from power.nix is a red
  # herring for this bug — kept only as harmless APST hygiene).
  #
  # DEFENSIVE MITIGATION (kept below): nvme_core.io_timeout=5 shortens each
  # stall from ~30s to <=5s. Now that AHCI removes VMD this should be a no-op
  # (there are no more lost interrupts to time out on), but it is harmless and
  # left as a seatbelt in case a future BIOS update silently reverts to RAID.
  # Safe because the completion is always already present when polled.
  boot.kernelParams = ["nvme_core.io_timeout=5"];

  # GUARD: keep the BIOS storage controller pinned to AHCI.
  #
  # The real fix for the VMD NVMe interrupt bug above lives in *firmware*, not
  # in this repo — we flipped Dell's "EmbSataRaid" HII setting from Raid to Ahci
  # via the dell-wmi-sysman driver. That value is stored in NVRAM, so nothing in
  # NixOS normally re-asserts it. A future BIOS update (or an NVRAM/CMOS reset)
  # can silently revert it to Raid, which would put VMD back in the data path
  # and bring back the ~30s per-I/O stalls with no obvious cause.
  #
  # This oneshot runs on every boot and re-writes Ahci ONLY if the value has
  # drifted. It is intentionally a no-op in the normal case: it never writes
  # when already Ahci (no NVRAM wear), it never reboots on its own (a corrected
  # value only takes effect on the *next* reboot), and it logs a loud warning
  # when it has to correct drift so the cause is obvious. Missing attribute
  # (e.g. driver not loaded / non-Dell) is treated as success and skipped.
  systemd.services.pin-ahci-storage-mode = {
    description = "Re-assert Dell BIOS EmbSataRaid=Ahci if it has drifted (VMD NVMe fix)";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [pkgs.coreutils];
    script = ''
      attr=/sys/class/firmware-attributes/dell-wmi-sysman/attributes/EmbSataRaid/current_value
      if [ ! -e "$attr" ]; then
        echo "EmbSataRaid attribute not present; skipping (dell-wmi-sysman not loaded or non-Dell)."
        exit 0
      fi
      current=$(cat "$attr")
      if [ "$current" = "Ahci" ]; then
        echo "EmbSataRaid already Ahci; nothing to do."
        exit 0
      fi
      echo "WARNING: EmbSataRaid drifted to '$current' — re-asserting Ahci. Reboot to remove VMD from the NVMe path." >&2
      echo Ahci > "$attr"
    '';
  };

  # Never sleep — long-running tasks must not be interrupted
  services.logind.settings.Login.HandleLidSwitch = "lock";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";
  services.logind.settings.Login.HandlePowerKey = "lock";
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "23.11";
}
