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
      grep = "rg";
      ls = "eza --icons always --classify always";
      la = "eza --icons always --classify always --all ";
      ll = "eza --icons always --long --all --git ";
      tree = "eza --icons always --classify always --tree";
      r = "ranger";
      cc = "clear";
      vim = "nvim";
      evim = "nvim ~/.config/dotfiles/nvim/init.lua";
      edot = "nvim ~/.config/dotfiles/home-manager/home.nix";
      reload = "exec zsh";
    };

    # setup eval "$(zoxide init zsh)" in zsh.nix
    initContent = ''
      eval "$(zoxide init zsh)"
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ~/.github_token)
      export OPENAI_API_KEY=$(cat ~/.openai_api_key)
      export PATH="$HOME/.npm-global/bin:$PATH"
    '';
  };
}
