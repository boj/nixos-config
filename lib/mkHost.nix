{
  inputs,
  system,
  username,
  userFullName,
  userEmail,
  sshKeys,
  defaultWallpaper,
}: {
  name,
  homeModule ? ../home/bojo.nix,
  extraModules ? [],
  stylix ? true,
}:
let
  specialArgs = {inherit inputs username sshKeys;};

  stylixModules =
    if stylix
    then [
      inputs.stylix.nixosModules.stylix
      ({pkgs, ...}: {
        stylix = {
          enable = true;
          image = defaultWallpaper;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          polarity = "dark";
          targets.chromium.enable = false;
        };
      })
    ]
    else [];

  hostHomePath = ../hosts/${name}/home.nix;
  homeModules =
    [homeModule]
    ++ (
      if builtins.pathExists hostHomePath
      then [hostHomePath]
      else []
    );
in
  inputs.nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules =
      [
        ../modules/nixos
        ../hosts/${name}
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = {imports = homeModules;};
          home-manager.extraSpecialArgs = {inherit inputs username userFullName userEmail defaultWallpaper;};
        }
      ]
      ++ stylixModules
      ++ extraModules;
  }
