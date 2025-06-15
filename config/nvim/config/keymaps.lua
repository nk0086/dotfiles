vim.g.mapleader = " "

vim.keymap.set({ "n", "v" }, "<leader>h", "^", { noremap = true })
vim.keymap.set({ "n", "v" }, "<leader>l", "$", { noremap = true })
vim.keymap.set({ "n", "v" }, "<leader>j", "10j", { noremap = true })
vim.keymap.set({ "n", "v" }, "<leader>k", "10k", { noremap = true })
vim.keymap.set({ "n", "v" }, ";", ":", { noremap = true })

vim.api.nvim_create_user_command('Source', 'source $MYVIMRC', {})

vim.keymap.set("n", "<leader>s", "<Cmd>vsplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true })

vim.keymap.set("n", "<leader>d", "<Cmd>bd<CR>")
vim.keymap.set("n", "H", "<Cmd>bp<CR>")
vim.keymap.set("n", "L", "<Cmd>bn<CR>")

-- telescope
vim.keymap.set("n", "<leader>o", function() require("telescope.builtin").find_files { hidden = true } end)
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files() end, { noremap = true })
vim.keymap.set("n", "<leader>fg", function() require("telescope.builtin").live_grep() end, { noremap = true })
vim.keymap.set("n", "<leader>fb", function() require("telescope.builtin").buffers() end, { noremap = true })
vim.keymap.set("n", "<leader>fr", function() require("telescope.builtin").oldfiles() end, { noremap = true })

-- formatting
vim.keymap.set({ "n", "v" }, "<leader>f", function()
    require("conform").format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
    })
end, { desc = "Format file or range (in visual mode)" })
