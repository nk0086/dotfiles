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

      # Read a token only on explicit invocation, inside a disposable subshell.
      _dotfiles_with_token() (
        set +x
        emulate -L zsh
        unsetopt verbose
        local token_name="$1" token_file="$2"
        local +x token
        shift 2
        if (( $# == 0 )); then
          print -u2 -- 'A command is required.'
          return 2
        fi
        case "$token_name" in
          GH_TOKEN|GITHUB_PERSONAL_ACCESS_TOKEN|OPENAI_API_KEY) ;;
          *) print -u2 -- 'Unsupported token variable.'; return 2 ;;
        esac
        if [[ ! -f "$token_file" || ! -r "$token_file" ]]; then
          print -u2 -- "Token file is missing or unreadable: $token_file"
          return 1
        fi
        if ! token=$(<"$token_file"); then
          print -u2 -- "Could not read token file: $token_file"
          return 1
        fi
        if [[ -z "$token" || "$token" == *[[:space:]]* ]]; then
          print -u2 -- "Token file must contain one nonempty token: $token_file"
          return 1
        fi
        # export is a shell builtin: the value never becomes a process argument.
        export "$token_name=$token"
        command "$@"
      )

      with-openai-key() {
        _dotfiles_with_token OPENAI_API_KEY "$HOME/.openai_api_key" "$@"
      }
      with-github-token() {
        _dotfiles_with_token GITHUB_PERSONAL_ACCESS_TOKEN "$HOME/.github_token" "$@"
      }
      gh-with-token() {
        _dotfiles_with_token GH_TOKEN "$HOME/.github_token" gh "$@"
      }

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
