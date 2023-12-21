{
  description = "bojo's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix.url = "github:helix-editor/helix/23.10";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    hyprland,
    hyprpaper,
    ...
  }: let
    system = "x86_64-linux";
    theme = import ./home/themes/nord;
  in {
    nixosConfigurations = {
      "bruh" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/bruh
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bojo = import ./home;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit theme;
            };
          }
          hyprland.nixosModules.default
          {
            programs.hyprland.enable = true;
          }
        ];
      };
    };
  };
}
