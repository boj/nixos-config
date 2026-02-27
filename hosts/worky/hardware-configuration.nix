# Placeholder — replace with output of:
#   nixos-generate-config --show-hardware-config
# run on the worky workstation.
{ lib, ... }: {
  imports = [];
  boot.initrd.availableKernelModules = [];
  boot.kernelModules = [];
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/boot"; fsType = "vfat"; };
}
