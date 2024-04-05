{
  pkgs,
  username,
  ...
}: {
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["${username}"];
}
