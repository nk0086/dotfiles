{pkgs, ...}: {
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
      copy = "pbcopy";
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
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ~/.github_token)
      export OPENAI_API_KEY=$(cat ~/.openai_api_key)
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH=$HOME/.cargo/bin:$PATH
      export EDITOR="nvim"
      export CARGO_BUILD_JOBS=12;
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
}
