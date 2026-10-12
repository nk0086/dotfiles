{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    historySubstringSearch = {
      enable = true;
      searchDownKey = "^N";
      searchUpKey = "^P";
    };

    history = {
      append = true;
      ignoreAllDups = true;
      # ignoreDups = true; ignoreAllDupsがあれば不要
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      cat = "bat";
      ls = "eza --icons always --classify always --ignore-glob='.DS_Store'";
      la = "eza --icons always --classify always --all --ignore-glob='.DS_Store'";
      ll = "eza --icons always --long --all --git --ignore-glob='.DS_Store'";
      tree = "eza --icons always --classify always --tree --ignore-glob='.DS_Store'";
      r = "ranger";
      cc = "clear && eza --icons always --long --all --git --ignore-glob='.DS_Store'";
      vim = "nvim";
      evim = "nvim ~/.config/dotfiles/nvim/init.lua";
      edot = "nvim ~/.config/dotfiles/home-manager/home.nix";
      reload = "exec zsh";
      eclaude = "nvim ~/.claude/settings.json";
      claude = "claude --mcp-config=$HOME/.claude/.mcp.json";
    };

    # setup eval "$(zoxide init zsh)" in zsh.nix
    initContent = ''
      eval "$(zoxide init zsh)"

      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH=$HOME/.cargo/bin:$PATH
      export EDITOR="nvim"
      export PATH="$HOME/.local/bin:$PATH"
      if [[ -r "$HOME/.safe-chain/scripts/init-posix.sh" ]]; then
        source "$HOME/.safe-chain/scripts/init-posix.sh"
      fi
    '';
  };
}
