{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelParams = ["kvm.enable_virt_at_load=0"];
}
