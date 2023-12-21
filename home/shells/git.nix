{pkgs, ...}: {
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    userName = "Brian Jones";
    userEmail = "bojo@bojo.wtf";
    extraConfig.init.defaultBranch = "main";
  };
}
