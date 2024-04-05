{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    qemu
    quickemu
    spice-gtk
    virt-manager
  ];
}
