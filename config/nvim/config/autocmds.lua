vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.cmd("colorscheme iceberg")
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})