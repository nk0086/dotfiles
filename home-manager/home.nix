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
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

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
      nix-output-monitor
      nix-search-cli
      nix-zsh-completions
      alejandra # nix
      docker
      ollama
      claude-code
      awscli2

      # extensions
      bat
      eza
      ripgrep
      zoxide

      # development tools
      proto
      rye
      uv
      deno
      nodejs_22
      vtsls
      lua-language-server # Lua
      stylua
      go
      zig
      rustup
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
