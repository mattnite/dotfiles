return {
    {
        'stevearc/conform.nvim',
        config = function()
            local conform = require("conform")
            conform.setup({
                formatters_by_ft = {
                    sql = { "sql_formatter" },
                },
            })

            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*",
                callback = function(args)
                    conform.format({ bufnr = args.buf })
                end,
            })
        end,
    }
}
-- use 'tpope/vim-fugitive'
