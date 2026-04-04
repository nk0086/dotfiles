vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("lspconfig").lua_ls.setup({})
		require("lspconfig").vtsls.setup({})
		require("lspconfig").pyright.setup({})
		require("lspconfig").gopls.setup({
			settings = {
				gopls = {
					gofumpt = true,
				},
			},
		})
		require("lspconfig").rust_analyzer.setup({
			settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
					},
					procMacro = {
						enable = true,
					},
				},
			},
		})
		require("lspconfig").nil_ls.setup({})
		require("lspconfig").nim_langserver.setup({})
		require("lspconfig").gleam.setup({})
	end,
})
