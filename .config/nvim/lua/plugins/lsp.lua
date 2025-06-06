return {
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-nvim-lsp-signature-help',
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')
            cmp.setup {
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            if luasnip.expandable() then
                                luasnip.expand()
                            else
                                cmp.confirm({ select = true })
                            end
                        else
                            fallback()
                        end
                    end),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.locally_jumpable(1) then
                            luasnip.jump(1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'nvim_lsp_signature_help' },
                    -- { name = 'luasnip' }, -- For luasnip users.
                }, {
                    { name = 'buffer' },
                    { name = 'path' },
                }),
            }
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp"
    },
    {
        'williamboman/mason-lspconfig.nvim',
        dependencies = {
            {
                'williamboman/mason.nvim',
                opts = {},
            },
            {
                'neovim/nvim-lspconfig',
            },
        },
        config = function()
            require('mason-lspconfig').setup()

            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local on_attach = function(client, bufnr)
                _ = client
                vim.api.nvim_create_autocmd('BufWritePre', {
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format()
                    end
                })

                -- 	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
                local wk = require('which-key')
                wk.add({
                    { 'gD',         vim.lsp.buf.declaration,    mode = 'n' },
                    { 'gd',         vim.lsp.buf.definition,     mode = 'n' },
                    { 'K',          vim.lsp.buf.hover,          mode = 'n' },
                    { 'gD',         vim.lsp.buf.implementation, mode = 'n' },
                    { '<C-k>',      vim.lsp.buf.signature_help, mode = 'n' },
                    { '<Leader>rn', vim.lsp.buf.rename,         mode = 'n' },
                    { '<Leader>ca', vim.lsp.buf.code_action,    mode = 'n' },
                    { '<Leader>lf', vim.lsp.buf.format,         mode = 'n' },
                })
            end



            require('mason-lspconfig').setup_handlers {
                function(server_name)
                    require('lspconfig')[server_name].setup {
                        capabilities = capabilities,
                        on_attach = on_attach,
                    }
                end,
                ['lua_ls'] = function()
                    require('lspconfig').lua_ls.setup {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        on_init = function(client)
                            if client.workspace_folders then
                                local path = client.workspace_folders[1].name
                                if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                                    return
                                end
                            end
                            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                                runtime = { version = 'LuaJIT' },
                                workspace = {
                                    checkThirdParty = false,
                                    library = { vim.env.VIMRUNTIME },
                                },
                            })
                        end,
                        settings = { Lua = {} }
                    }
                end,
                ['yamlls'] = function()
                    require('lspconfig').yamlls.setup {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            yaml = {
                                schemas = {
                                    ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                                },
                            },
                        },
                    }
                end,
            }

            -- Manually installed LSPs
            require('lspconfig').zls.setup {
                capabilities = capabilities,
                on_attach = on_attach,
            }
        end,
    },
}
