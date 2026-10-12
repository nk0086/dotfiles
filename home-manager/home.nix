{
  inputs,
  pkgs,
  ...
}: let
  # Flake evaluation is pure by default. Build/switch must opt into --impure
  # so that this profile belongs to the invoking user's environment.
  requiredEnv = name: let
    value = builtins.getEnv name;
  in
    if value == ""
    then throw "dotfiles: ${name} is empty or unavailable; export ${name} for the intended user and evaluate with --impure (do not use sudo)."
    else value;
  username = requiredEnv "USER";
  homeDirectory = requiredEnv "HOME";
in {
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  };

  imports = [
    ./programs/direnv.nix
    ./programs/zsh.nix
    ./programs/bat.nix
    ./programs/eza.nix
    ./programs/gh.nix
    ./programs/neovim.nix
  ];

  home = {
    inherit username;
    homeDirectory =
      if builtins.substring 0 1 homeDirectory == "/"
      then homeDirectory
      else throw "dotfiles: HOME must be an absolute path for the intended user.";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    file = {
      # nvim
      ".config/nvim" = {
        source = ../config/nvim;
        recursive = true;
      };

      # tig
      ".tigrc".source = ../config/.tigrc;
    };

    packages = with pkgs; [
      # base packages
      git
      git-extras
      git-interactive-rebase-tool
      git-quick-stats
      git-recent
      git-trim
      git-workspace
      curl
      fzf
      neovim
      ranger
      starship
      gh
      nil
      nix-output-monitor
      nix-search-cli
      nix-zsh-completions
      alejandra # nix
      docker
      # ollama
      # claude-code
      awscli2
      tig
      cmake
      luajitPackages.luarocks_bootstrap
      go-task
      redocly
      openssl
      pkgconf
      online-judge-tools
      mise

      # extensions
      bat
      eza
      ripgrep
      zoxide
      delta
      httpie

      # development tools
      proto
      rye
      uv
      pnpm
      python314
      deno
      nodejs_22
      vtsls
      lua-language-server # Lua
      stylua
      go
      gotools # goimports
      zig
      nim
      erlang_27 # Erlang
      gleam
      rebar3
      ltex-ls # 文法・スペルチェック用Language Server
      typos-lsp # タイポ検出用Language Server
    ];
  };

  programs.home-manager.enable = true;
  programs.starship.enable = true;
}
