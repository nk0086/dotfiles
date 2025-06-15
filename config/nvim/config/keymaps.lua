vim.g.mapleader = " "

vim.keymap.set({ "n", "v" }, "<leader>h", "^", { noremap = true })
vim.keymap.set({ "n", "v" }, "<leader>l", "$", { noremap = true })
vim.keymap.set({ "n", "v" }, "<leader>j", "10j", { noremap = true })
vim.keymap.set({ "n", "v" }, "<leader>k", "10k", { noremap = true })
vim.keymap.set({ "n", "v" }, ";", ":", { noremap = true })

vim.api.nvim_create_user_command("Source", "source $MYVIMRC", {})

vim.keymap.set("n", "<leader>s", "<Cmd>vsplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true })

vim.keymap.set("n", "<leader>d", "<Cmd>bd<CR>")
vim.keymap.set("n", "H", "<Cmd>bp<CR>")
vim.keymap.set("n", "L", "<Cmd>bn<CR>")

-- telescope
vim.keymap.set("n", "<leader>o", function()
	require("telescope.builtin").find_files({ hidden = true })
end)
vim.keymap.set("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { noremap = true })
vim.keymap.set("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { noremap = true })
vim.keymap.set("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { noremap = true })
vim.keymap.set("n", "<leader>fr", function()
	require("telescope.builtin").oldfiles()
end, { noremap = true })

-- nvim-tree
local function my_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
	vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
end

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- pass to setup along with your other options
require("nvim-tree").setup({
	---
	on_attach = my_on_attach,
	---
})
