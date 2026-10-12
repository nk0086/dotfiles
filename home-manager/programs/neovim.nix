{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (plugins:
        with plugins; [
          packer-nvim
          tree-sitter-markdown
          tree-sitter-nix
          tree-sitter-lua
          tree-sitter-go
          tree-sitter-python
          tree-sitter-typescript
          tree-sitter-javascript
          tree-sitter-json
          tree-sitter-yaml
          tree-sitter-rust
          # ...
        ]))
      telescope-nvim
      # ...
    ];

    # Neovim内部でのみPATHが通されるパッケージ
    extraPackages = with pkgs; [
      ripgrep
      biome
      nodePackages.eslint
      nodePackages.prettier

      # Executables used by config/nvim/config/lsp.lua.
      lua-language-server
      vtsls
      pyright
      gopls
      rust-analyzer
      nil
      nimlangserver
      gleam

      # Formatters used by config/nvim/config/formatters.lua.
      rustfmt
      go # gofmt
      gotools # goimports
      black
      ruff
      nim # nimpretty and nimsuggest
      alejandra
      stylua

      # rust-analyzer project discovery / proc macros and native lazy plugins.
      cargo
      rustc
      gnumake
      stdenv.cc
    ];
  };
}
