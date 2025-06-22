local config_path = vim.fn.stdpath("config")
package.path = package.path .. ";" .. config_path .. "/?.lua;" .. config_path .. "/plugins/?.lua"

vim.g.copilot_filetypes = {
	markdown = true,
	gitcommit = true,
	yaml = true,
}

require("plugins.plugins")
require("plugins.lualine")
require("plugins.nvim-tree")
require("config.options")
require("config.keymaps")
require("config.lsp")
require("config.formatters")
require("config.autocmds")
require("config.terminal")
