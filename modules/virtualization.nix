{pkgs, ...}: {
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["bojo"];

  environment.systemPackages = with pkgs; [
    qemu
    quickemu
    spice-gtk
    virt-manager
  ];
}
