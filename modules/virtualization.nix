{
  pkgs,
  username,
  ...
}: {
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["${username}"];

  environment.systemPackages = with pkgs; [
    qemu
    quickemu
    spice-gtk
    virt-manager
  ];
}
