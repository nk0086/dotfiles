{config, ...}: {
  imports = [../programs/wezterm.nix];

  home.homeDirectory = "/Users/${config.home.username}";
  programs.zsh.shellAliases.copy = "pbcopy";
}
