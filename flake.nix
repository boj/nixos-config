{
  description = "bojo's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?rev=0002f148c9a4fe421a9d33c0faa5528cdc411e62";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprland-contrib.url = "github:hyprwm/contrib";
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixos-wsl,
    ...
  }: let
    system = "x86_64-linux";
    username = "bojo";
    specialArgs = {inherit inputs username;};
    defaultWallpaper = ./hyprland.png;
    stylixConfig = {pkgs, ...}: {
      stylix = {
        enable = true;
        image = ./hyprland.png;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        polarity = "dark";
        targets.chromium.enable = false;
      };
    };
  in {
    nixosConfigurations = {
      "bruh" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nixos
          ./hosts/bruh
          inputs.stylix.nixosModules.stylix
          stylixConfig
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = {
              imports = [
                (import ./home/bojo.nix)
                inputs.caelestia-shell.homeManagerModules.default
              ];
              my.gpu = "amd";
              my.wayland.hyprland.useFunctionKeys = true;
              my.wayland.hyprland.monitors = [
                "DP-1,1920x1080@240,0x0,1"
                "DP-3,1920x1080@240,1920x0,1"
              ];
              my.wayland.hyprland.execOnce = [
                "[workspace 1 silent] firefox"
              ];
            };
            home-manager.extraSpecialArgs = {inherit inputs username defaultWallpaper;};
          }
        ];
      };
      "worky" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nixos
          ./hosts/worky
          inputs.stylix.nixosModules.stylix
          stylixConfig
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = {
              imports = [
                (import ./home/bojo.nix)
                inputs.caelestia-shell.homeManagerModules.default
              ];
              my.gpu = "nvidia";
              my.wayland.hyprland.monitors = [
                "desc:Dell Inc. DELL P2417H KH0NG77E1VVB,1920x1080@60,0x0,1"
                "desc:Dell Inc. DELL P2417H KH0NG7873KDI,1920x1080@60,1920x0,1"
                "desc:AU Optronics 0x97A2,3840x2160@120,0x1080,2"
              ];
              my.wayland.hyprland.workspaces = [
                "1, monitor:desc:Dell Inc. DELL P2417H KH0NG77E1VVB, default:true"
                "2, monitor:desc:Dell Inc. DELL P2417H KH0NG77E1VVB"
                "3, monitor:desc:Dell Inc. DELL P2417H KH0NG77E1VVB"
                "4, monitor:desc:Dell Inc. DELL P2417H KH0NG7873KDI, default:true"
                "5, monitor:desc:Dell Inc. DELL P2417H KH0NG7873KDI"
                "6, monitor:desc:Dell Inc. DELL P2417H KH0NG7873KDI"
                "7, monitor:desc:AU Optronics 0x97A2, default:true"
                "8, monitor:desc:AU Optronics 0x97A2"
                "9, monitor:desc:AU Optronics 0x97A2"
              ];
              my.wayland.kanshi = {
                enable = true;
                profiles = {
                  docked = {
                    outputs = [
                      {
                        criteria = "Dell Inc. DELL P2417H KH0NG77E1VVB";
                        mode = "1920x1080@60";
                        position = "0,0";
                      }
                      {
                        criteria = "Dell Inc. DELL P2417H KH0NG7873KDI";
                        mode = "1920x1080@60";
                        position = "1920,0";
                      }
                      {
                        criteria = "eDP-1";
                        mode = "3840x2160@120";
                        position = "0,1080";
                      }
                    ];
                    exec = [
                      "move-workspaces 1:DP-8 2:DP-8 3:DP-8 4:DP-7 5:DP-7 6:DP-7 7:eDP-1 8:eDP-1 9:eDP-1"
                    ];
                  };
                  undocked = {
                    outputs = [
                      {
                        criteria = "eDP-1";
                        mode = "3840x2160@60";
                        position = "0,0";
                      }
                    ];
                  };
                };
              };
              my.wayland.hyprland.execOnce = [
                "[workspace 1 silent] firefox"
              ];
              my.wayland.hyprland.idleTimeout = 1200;
            };
            home-manager.extraSpecialArgs = {inherit inputs username defaultWallpaper;};
          }
        ];
      };
      "wsl" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nixos
          ./hosts/wsl
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home/wsl.nix;
            home-manager.extraSpecialArgs = {inherit inputs username defaultWallpaper;};
          }
        ];
      };
    };
  };
}
