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
            vim.cmd("wincmd l")
            vim.api.nvim_win_set_buf(0, terminal_bufnr)
            vim.cmd("startinsert")
        end
    else
        vim.cmd("vsplit")
        vim.cmd("wincmd l")
        vim.cmd("terminal")
        terminal_bufnr = vim.api.nvim_get_current_buf()
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = terminal_bufnr, noremap = true, silent = true })
        vim.cmd("startinsert")
    end
end, { noremap = true, silent = true })