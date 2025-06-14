vim.cmd [[packadd packer.nvim]]

require("packer").startup(function(use)
    use { "wbthomason/packer.nvim" }
    use { "nvim-lua/plenary.nvim" }
    use {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        requires = { "nvim-lua/plenary.nvim" },
    }
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use { "machakann/vim-sandwich" }
    use { "rhysd/clever-f.vim" }
    use { "iberianpig/tig-explorer.vim" }
    use { "cocopon/iceberg.vim" }
    use { "tpope/vim-commentary" }
    use { "neovim/nvim-lspconfig" }
end)