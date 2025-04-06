{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    qemu
    # quickemu
    spice
    spice-gtk
    virt-manager
    virt-viewer
    win-virtio
    win-spice

    edk2
    swtpm
  ];

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";

    qemu = {
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMFFull.override
            {
              secureBoot = true;
              tpmSupport = true;
            })
          .fd
        ];
      };
      swtpm.enable = true;
      runAsRoot = false;
    };
  };
  programs.virt-manager.enable = true;
}
