{ config, lib, pkgs, ... }:
let cfg = config.my.virtualization.general; in {
  options.my.virtualization.general.enable = lib.mkEnableOption "libvirtd/QEMU";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      qemu
      spice
      spice-gtk
      virt-manager
      virt-viewer
      virtio-win
      win-spice

      edk2
      swtpm
    ];

    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";

      qemu = {
        swtpm.enable = true;
        runAsRoot = false;
      };
    };
    programs.virt-manager.enable = true;
  };
}
