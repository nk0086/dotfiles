local config_path = vim.fn.stdpath("config")
package.path = package.path .. ";" .. config_path .. "/?.lua;" .. config_path .. "/plugins/?.lua"

require("plugins.plugins")
require("config.options")
require("config.keymaps")
require("config.lsp")
require("config.formatters")
require("config.autocmds")
require("config.terminal")
