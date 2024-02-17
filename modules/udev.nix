{
  services.udev.extraRules = builtins.readFile ../data/50-zsa.rules;
}
