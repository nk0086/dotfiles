{config, ...}: {
  home.homeDirectory = "/home/${config.home.username}";

  # Keep the Linux profile usable on headless hosts. For a desktop, add
  # ../programs/wezterm.nix to imports here.
}
