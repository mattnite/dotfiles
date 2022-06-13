vim.cmd('packadd packer.nvim')
local packer = require'packer'
local util = require'packer.util'
packer.init({
  package_root = util.join_paths(vim.fn.stdpath('data'), 'site', 'pack')
})

-- needs to be relatively high up
vim.g.mapleader = " "

--- startup and add configure plugins
packer.startup(function()
  local use = use
  use 'wbthomason/packer.nvim' -- Package manager
  use 'neovim/nvim-lspconfig' -- Collection of configurations for the built-in LSP client
  use 'sainnhe/sonokai' -- color scheme
  use 'nvim-treesitter/nvim-treesitter'
  use 'ziglang/zig.vim'
  use 'ntpeters/vim-better-whitespace'
  use 'kevinhwang91/nvim-bqf' -- Preview window for quickfix
  use 'ray-x/lsp_signature.nvim'
  use 'glepnir/lspsaga.nvim'

  use {
    'junegunn/fzf.vim',
    requires = {
      'junegunn/fzf'
    }
  }

  use {
    'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp
    requires = {
      'L3MON4D3/LuaSnip', -- Snippets plugin
    }
  }

  use {
    'hrsh7th/nvim-cmp', -- Autocompletion plugin
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
    }
  }

  use { -- signs in the gutter for git and other things?
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  }

  use {
    'nvim-lualine/lualine.nvim', -- status line
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  use {
    "folke/zen-mode.nvim", -- chill writing mode
    config = function()
      require("zen-mode").setup {
        window = {
          backdrop = 0.95,
          width = 100,
        },
      }
    end
  }
  end
)

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'sonokai',
  },
}

require'nvim-treesitter.configs'.setup {
  --ensure_installed = "maintained",
  sync_install = false,
  highlight = {
    enable = true,
    disable = { 'zig' },
    additional_vim_regex_highlighting = false,
  },
}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  --vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'zls' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- signature helper
require "lsp_signature".setup()

-- lsp ui stuff: TODO look into this later for more cool things to add
require 'lspsaga'.init_lsp_saga()

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- mappings
vim.api.nvim_set_keymap('n', '<Leader>rn', '', {
    noremap = true,
    callback = function()
      require('lspsaga.rename').rename()
    end,
    desc = 'rename a token using LSP',
})

--   fzf mappings
vim.api.nvim_set_keymap('n', '<Leader>gf', ':GFiles<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>rg', ':Rg<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>z', ':ZenMode<CR>', { noremap = true, silent = true })

-- basic vim options
vim.cmd('colorscheme sonokai')
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.linebreak = true
vim.opt.wrap = false
vim.opt.termguicolors = true
