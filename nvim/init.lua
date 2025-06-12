vim.cmd [[packadd packer.nvim]]

-- plugin
require("packer").startup(function(use)
    use { "wbthomason/packer.nvim" }
    use { "nvim-lua/plenary.nvim" }
    use {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.6",
        requires = { "nvim-lua/plenary.nvim" },
        cmd = "Telescope", -- lazy-load
    }
    use { "machakann/vim-sandwich", event = "InsertEnter" }
    use { "rhysd/clever-f.vim", event = "BufRead" }
    use { "iberianpig/tig-explorer.vim", cmd = { "TigOpenCurrentFile", "TigOpenProjectRootDir" } }
    use { "cocopon/iceberg.vim", event = "Vimenter" }
    use { "tpope/vim-commentary", keys = { "gc", "gcc" } }
    use { "neovim/nvim-lspconfig" }
end)

vim.cmd("filetype plugin indent on")

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.cmd("colorscheme iceberg")
    end,
})

-- keymap
vim.g.mapleader = " "
vim.keymap.set({ "n", "v" }, "<leader>h", "^", { noremap = true })
vim.keymap.set({ "n", "v" }, "<leader>l", "$", { noremap = true })
vim.keymap.set({ "n", "v" }, "<leader>j", "10j", { noremap = true })
vim.keymap.set({ "n", "v" }, "<leader>k", "10k", { noremap = true })
vim.keymap.set({ "n", "v" }, ";", ":", { noremap = true })
vim.api.nvim_create_user_command('Source', 'source $MYVIMRC', {})

vim.keymap.set("n", "<leader>s", "<Cmd>vsplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true }) -- 左移動
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true }) -- 右移動

vim.keymap.set("n", "<leader>o", function() require("telescope.builtin").find_files { hidden = true } end)
vim.keymap.set("n", "<leader>d", "<Cmd>bd<CR>")
vim.keymap.set("n", "H", "<Cmd>bp<CR>")
vim.keymap.set("n", "L", "<Cmd>bn<CR>")
-- telescope
local function load_telescope()
    require("packer").loader("telescope.nvim")
    return require("telescope.builtin")
end
vim.keymap.set("n", "<leader>ff", function() load_telescope().find_files() end, { noremap = true })
vim.keymap.set("n", "<leader>fg", function() load_telescope().live_grep() end, { noremap = true })
vim.keymap.set("n", "<leader>fb", function() load_telescope().buffers() end, { noremap = true })
vim.keymap.set("n", "<leader>fr", function() load_telescope().oldfiles() end, { noremap = true })

-- options
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.scrolloff = 6
vim.opt.list = true
vim.opt.listchars = { tab = ">-", trail = "-" }
vim.opt.cursorline = true
vim.opt.completeopt = "menuone"
vim.opt.termguicolors = true

-- format when save file
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

-- lsp
local on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
        local group = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = group,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end,
        })
    end
end

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        require("lspconfig").lua_ls.setup { on_attach = on_attach }
        require("lspconfig").ts_ls.setup { on_attach = on_attach }
        require("lspconfig").pyright.setup { on_attach = on_attach }
        require("lspconfig").gopls.setup { on_attach = on_attach }
    end,
})

--
local terminal_bufnr = nil

vim.keymap.set("n", "<C-t>", function()
    if terminal_bufnr and vim.api.nvim_buf_is_valid(terminal_bufnr) then
        local wins = vim.api.nvim_list_wins()
        local is_open = false
        for _, win in ipairs(wins) do
            if vim.api.nvim_win_get_buf(win) == terminal_bufnr then
                vim.api.nvim_win_close(win, true)
                is_open = true
                break
            end
        end
        if not is_open then
            vim.cmd("vsplit")
            vim.cmd("wincmd l") -- 右のウィンドウに移動！
            vim.api.nvim_win_set_buf(0, terminal_bufnr)
            vim.cmd("startinsert")
        end
    else
        vim.cmd("vsplit")
        vim.cmd("wincmd l") -- 右のウィンドウに移動！
        vim.cmd("terminal")
        terminal_bufnr = vim.api.nvim_get_current_buf()
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = terminal_bufnr, noremap = true, silent = true })
        vim.cmd("startinsert")
    end
end, { noremap = true, silent = true })
