{ pkgs, ... }: {
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
      nodePackages.typescript-language-server
      # ...
    ];

    extraLuaConfig = builtins.readFile ../../nvim/init.lua;
  };
}
