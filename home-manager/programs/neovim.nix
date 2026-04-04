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
      # ...
    ];
  };
}
