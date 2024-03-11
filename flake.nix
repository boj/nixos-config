{
  description = "bojo's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix.url = "github:helix-editor/helix";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixos-wsl,
    nix-colors,
    home-manager,
    hyprland,
    hyprpaper,
    hyprland-contrib,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      "bruh" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/bruh
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bojo = import ./home/profiles/bojo;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit nix-colors;
            };
          }
          hyprland.nixosModules.default
          {
            programs.hyprland.enable = true;
          }
        ];
      };
      "wsl" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/wsl
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bojo = import ./home/profiles/wsl;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };
    };
  };
}
