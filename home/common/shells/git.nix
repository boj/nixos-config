{pkgs, userFullName, userEmail, ...}: {
  home.packages = with pkgs; [
    git
    git-lfs
  ];

  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      user.name = userFullName;
      user.email = userEmail;
      init.defaultBranch = "main";
    };
  };
}
