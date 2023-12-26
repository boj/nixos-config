{pkgs, ...}: {
  home.packages = with pkgs; [
    openfortivpn
    microsoft-edge
  ];
}
