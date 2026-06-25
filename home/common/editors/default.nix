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
    userSettings = {
      assistant = {
        default_model = {
          provider = "copilot_chat";
          model = "claude-4-7-opus-latest";
        };
      };
    };
  };
}
