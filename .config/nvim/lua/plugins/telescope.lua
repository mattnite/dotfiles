return {
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.4',
		dependencies = {
			'nvim-lua/plenary.nvim'
		},
		opts = {},
		config = function()
			require'telescope'.setup{}
			local builtin = require('telescope.builtin')
			local wk = require('which-key')
			wk.add({
				{ '<Leader>ff', builtin.find_files, mode = 'n', desc = "Find files" },
				{ '<Leader>lg', builtin.live_grep,  mode = 'n', desc = "Live grep" },
				{ '<Leader>fb', builtin.builtin,    mode = 'n', desc = "Find pickers" },
			})
		end,
	},
}
