{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    wine
  ];
}
