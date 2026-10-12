{lib, ...}: {
  imports = [../programs/wezterm.nix];

  programs.zsh = {
    shellAliases.copy = "pbcopy";
    initContent = lib.mkBefore ''
      if [[ -t 0 ]]; then
        export GPG_TTY=$(tty)
      fi
      if (( $+commands[gpgconf] )); then
        if gpgconf --launch gpg-agent \
          && _dotfiles_gpg_ssh_socket=$(gpgconf --list-dirs agent-ssh-socket) \
          && [[ -n "$_dotfiles_gpg_ssh_socket" ]]; then
          export SSH_AUTH_SOCK="$_dotfiles_gpg_ssh_socket"
        fi
        unset _dotfiles_gpg_ssh_socket
      fi
      export CARGO_BUILD_JOBS=12
    '';
  };
}
