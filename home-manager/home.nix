{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  username = "nk";
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
    username = username;
    homeDirectory = "/Users/${username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    file = {
      # nvim
      ".config/nvim" = {
        source = ../config/nvim;
        recursive = true;
      };

      # wezterm
      ".config/wezterm/wezterm.lua".source = ../config/wezterm/wezterm.lua;

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
      wezterm
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
