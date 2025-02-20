return {
	{
		'srcery-colors/srcery-vim',
		config = function()
      			vim.cmd([[colorscheme srcery]])
      		end,
	},
	{ 'ntpeters/vim-better-whitespace' },
	{
		'nvim-lualine/lualine.nvim',
		dependencies = {
			'nvim-tree/nvim-web-devicons'
	    	},
	    	opts = {
		    	options = {
				icons_enabled = true,
    				section_separators = { left = '', right = ''},
		    	},
		},
	},
	{ 'lewis6991/gitsigns.nvim', opts = {} },
}

