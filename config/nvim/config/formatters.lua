require("conform").setup({
    formatters_by_ft = {
        rust = { "rustfmt" },
        go = { "gofmt", "goimports" },
        python = { "black", "ruff_format" },
        nim = { "nimpretty" },
        nix = { "alejandra" },
        lua = { "stylua" },
        typescript = { "prettier" },
        javascript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        gleam = { "gleam" },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },
})
