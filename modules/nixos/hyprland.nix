{ config, lib, inputs, ... }:
let cfg = config.my.hyprland; in {
  imports = [inputs.hyprland.nixosModules.default];
  options.my.hyprland.enable = lib.mkEnableOption "Hyprland";
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    # Hyprland's setuid wrapper (/run/wrappers/bin/Hyprland,
    # cap_setpcap,cap_sys_nice=ep) raises CAP_SYS_NICE into its *ambient* set
    # for realtime scheduling, and that ambient capability is inherited by
    # every app the session spawns (Chromium, Electron, etc.).
    #
    # With fs.suid_dumpable=2 (the default), any process holding a capability
    # beyond what its uid would grant is marked non-dumpable, which makes its
    # /proc/<pid>/root owned by root. xdg-desktop-portal (an unprivileged
    # user service) opens /proc/<caller>/root to identify callers; when it
    # can't, it rejects *every* request with
    #   AccessDenied: Portal operation not allowed: Unable to open /proc/<pid>/root
    # Chromium's startup portal-availability probe then fails, so it disables
    # the portal file picker for the whole session and falls back to a GTK
    # dialog that never maps under pure Wayland — i.e. "Choose File" /
    # file-upload dialogs silently do nothing.
    #
    # suid_dumpable=1 keeps these processes user-dumpable, so their /proc
    # entries stay user-owned and the portal can identify callers again. The
    # only effect is that core dumps of capability-holding user processes are
    # readable by this (single) user, which is acceptable here.
    boot.kernel.sysctl."fs.suid_dumpable" = 1;
  };
}
