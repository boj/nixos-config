{pkgs, ...}: {
  imports = [
    ./helix.nix
  ];

  programs.zed-editor = {
    enable = true;
    extensions = [
      "css"
      "docker"
      "html"
      "javascript"
      "nix"
      "rust"
      "sql"
      "toml"
      "zig"
    ];
  };
}
