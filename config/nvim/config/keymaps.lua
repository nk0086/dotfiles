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

-- get_git_root function
local function get_git_root()
	local stdout = vim.fn.systemlist("git rev-parse --show-toplevel")
	if vim.v.shell_error == 0 and #stdout > 0 then
		return stdout[1]
	end
	return vim.fn.getcwd()
end

-- Comment.nvim
vim.keymap.set("n", "<leader>/", function()
	require("Comment.api").toggle.linewise.current()
end, { noremap = true, silent = true })

-- telescope
vim.keymap.set("n", "<leader>p", function()
	require("telescope.builtin").find_files({ cwd = get_git_root() })
end, { noremap = true })
vim.keymap.set("n", "<leader>ff", function()
	require("telescope.builtin").live_grep({ cwd = get_git_root() })
end, { noremap = true })
vim.keymap.set("n", "<leader>fg", function()
	require("telescope.builtin").git_commits({ cwd = get_git_root() })
end, { noremap = true })
vim.keymap.set("n", "<leader>fs", function()
	require("telescope.builtin").git_status({ cwd = get_git_root() })
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
	update_focused_file = {
		enable = true,
		update_root = true,
	},
	---
})
