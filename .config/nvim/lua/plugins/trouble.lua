return {
  	{
		'folke/trouble.nvim',
		opts = {},
		init = function()
			local wk = require('which-key')
			wk.add({
				{ '<Leader>xx', '<cmd>Trouble diagnostics toggle<CR>',                        mode = 'n', desc = 'Diagnostics (Trouble)' },
				{ '<Leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>',           mode = 'n', desc = 'Buffer Diagnostics (Trouble)' },
				{ '<Leader>cs', '<cmd>Trouble symbols toggle focus=false<CR>',                mode = 'n', desc = 'Symbols (Trouble)' },
				{ '<Leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<CR>', mode = 'n', desc = 'LSP Definitions / references / ... (Trouble)' },
				{ '<Leader>xL', '<cmd>Trouble loclist toggle<CR>',                            mode = 'n', desc = 'Location List (Trouble)' },
				{ '<Leader>xQ', '<cmd>Trouble qflist toggle<CR>',                             mode = 'n', desc = 'Quickfix List (Trouble)' },
			})
		end,
	},
}
