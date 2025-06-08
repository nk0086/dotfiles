{
  programs.direnv = {
    enable = true;
    config = {
      disable_stdin = true;
      strict_env = true;
      warn_timeout = 0;
    };
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
