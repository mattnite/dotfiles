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
			cmp.setup{
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
								cmp.confirm({select = true})
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
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		build = "make install_jsregexp"
	},
	{
    		'williamboman/mason-lspconfig.nvim',
		version = 'v1.31.0',
		dependencies = {
			{
    				'williamboman/mason.nvim',
				version = 'v1.10.0',
				opts = {},
			},
			{
				'neovim/nvim-lspconfig',
				version = 'v1.3.0',
			},
		},
		config = function()
			require('mason-lspconfig').setup()

			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			local on_attach = function(client ,bufnr)
				if client.resolved_capabilities.document_formatting then
					vim.api.nvim_create_autocmd('BufWritePre', {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format()
						end
					})
				end

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
					{ '<Leader>f',  vim.lsp.buf.format,         mode = 'n' },
				})
			end

			require('mason-lspconfig').setup_handlers{
				function(server_name)
					require('lspconfig')[server_name].setup{
						capabilities,
						on_attach,
					}
				end,
				['lua_ls'] = function()
					require('lspconfig').lua_ls.setup{
						capabilities,
						on_attach,
						on_init = function(client)
							if client.workspace_folders then
								local path = client.workspace_folders[1].name
								if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
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
					require('lspconfig').yamlls.setup{
						capabilities,
						on_attach,
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
		end,
	},
	{
  		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		version = 'v3.0.0',
		config = function()
                	local lsp_lines = require('lsp_lines')
                	lsp_lines.setup()
                	vim.diagnostic.config({
                		virtual_text = false,
                	         update_in_insert = false,
                	})

			local wk = require('which-key')
			wk.add({
				{ '<Leader>li', lsp_lines.toggle, mode = 'n', desc = 'Toggle lsp_lines' },
			})
		end
	},
}
