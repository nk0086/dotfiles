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
        require("lspconfig").gopls.setup { 
            on_attach = on_attach,
            settings = {
                gopls = {
                    gofumpt = true,
                },
            },
        }
        require("lspconfig").rust_analyzer.setup { 
            on_attach = on_attach,
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
        }
        require("lspconfig").nil_ls.setup { on_attach = on_attach }
        require("lspconfig").nim_langserver.setup { on_attach = on_attach }
        require("lspconfig").gleam.setup { on_attach = on_attach }
    end,
})