{
  pkgs,
  lib,
  config,
  username,
  ...
}: {
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://hyprland.cachix.org"
    "https://helix.cachix.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Anchorage";

  # Allow for quick ephemeral edits
  environment.etc.hosts.mode = "0644";

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  environment.systemPackages = with pkgs; [
    cachix
    curl
    git
    mosh
    nh
    nvd
    wget
  ];

  # Print a package diff between the running system and the one being activated.
  # Runs on every switch/boot/test — nh, nixos-rebuild, deploy-rs all trigger it.
  system.activationScripts.report-changes = ''
    if [[ -e /run/current-system ]] && [[ "$(readlink /run/current-system)" != "$systemConfig" ]]; then
      echo
      echo "--- system diff ---"
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig" || true
      echo
    fi
  '';

  # Allow mosh UDP traffic
  networking.firewall.allowedUDPPortRanges = [{from = 60000; to = 61000;}];

  environment.localBinInPath = true;

  programs.fish.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "docker"
      "input"
      "libvirtd"
      "plugdev"
      "sound"
      "tty"
      "video"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  nix.settings.trusted-users = [username];
}
