{pkgs, ...}: {
  home.packages = with pkgs; [
    git
    git-lfs
  ];

  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      user.name = "Brian Jones";
      user.email = "bojo@bojo.wtf";
      init.defaultBranch = "main";
    };
  };
}
