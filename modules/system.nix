{
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Anchorage";

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    wget
  ];
}
