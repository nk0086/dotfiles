-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "nvim-lua/plenary.nvim" },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    },
    { "machakann/vim-sandwich" },
    { "rhysd/clever-f.vim" },
    { "iberianpig/tig-explorer.vim" },
    { "cocopon/iceberg.vim" },
    { "rebelot/kanagawa.nvim" },
    { "tpope/vim-commentary" },
    { "neovim/nvim-lspconfig" },
    {
        "stevearc/conform.nvim",
        opts = {},
    },
    -- https://github.com/nvim-tree/nvim-tree.lua
    { "nvim-tree/nvim-tree.lua" },
    {
        "RRethy/vim-illuminate",
        config = function()
            require("illuminate").configure({
                providers = {
                    "lsp",
                    "treesitter",
                    "regex",
                },
                delay = 100,
                filetype_overrides = {},
                filetypes_denylist = {
                    "dirvish",
                    "fugitive",
                },
                under_cursor = true,
            })
        end,
    },
    { "github/copilot.vim" },
    { "numToStr/Comment.nvim" },
    { "lewis6991/gitsigns.nvim", opts = {} },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("lualine")
        end,
    },

    { "akinsho/bufferline.nvim",  version = "v3.*" },
    -- keymapの候補表示
    { "folke/which-key.nvim" },
    { "folke/todo-comments.nvim", opts = {} },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
    },
    -- 中央寄せ
    {
        "folke/zen-mode.nvim",
        opts = {},
    },
    -- 通知
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {},
    },
    -- {
    --     "folke/persistence.nvim",
    --     event = "BufReadPre",
    --     opts = {},
    -- },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
    },
})
