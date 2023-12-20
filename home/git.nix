{pkgs, config, ...}:

{
  programs.git = {
    enable = true;
    userName = "Brian Jones";
    userEmail = "bojo@bojo.wtf";
    extraConfig.init.defaultBranch = "main";
  };
}
