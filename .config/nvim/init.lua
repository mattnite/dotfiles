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
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/nvim-treesitter-context'
  use 'ziglang/zig.vim'
  use 'ntpeters/vim-better-whitespace'
  use 'kevinhwang91/nvim-bqf' -- Preview window for quickfix
  use 'ray-x/lsp_signature.nvim'
  use 'glepnir/lspsaga.nvim'
  use 'tpope/vim-fugitive'
  use 'renerocksai/telekasten.nvim'

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {
    'nvim-telescope/telescope-media-files.nvim',
    requires = {
      { 'nvim-lua/popup.nvim' },
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope.nvim' },
    },
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

  use {
    "folke/which-key.nvim", -- popup for motions and other hints
    config = function()
      require("which-key").setup {
        window = {
          border = 'single',

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
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
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

require'treesitter-context'.setup()

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
local servers = { 'clangd', 'zls', 'pylsp', 'gopls', 'bashls' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig.yamlls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    yaml = {
      schemas = {
        kubernetes = "*",
      },
      --schemaStore = {
      --  enable = true,
      --},
    },
  },
}

lspconfig.sumneko_lua.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

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
vim.api.nvim_set_keymap('n', '<Leader>ca', ':Lspsaga code_action<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>gn', ':Lspsaga lsp_finder<CR>', { noremap = true, silent = true })

-- Telescope
-- see more bultin pickers here: https://github.com/nvim-telescope/telescope.nvim#pickers
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>ff', builtin.find_files, { desc = "find files" })
vim.keymap.set('n', '<Leader>fg', builtin.find_files, { desc = "find git files" })
vim.keymap.set('n', '<Leader>lg', builtin.live_grep, { desc = "live grep" })
vim.keymap.set('n', '<Leader>fb', builtin.buffers, { desc = "find buffers" })

require('telescope').load_extension('media_files')

-- telekasten
local home = vim.fn.expand("~/telekasten")
local telekasten = require('telekasten');
telekasten.setup{
  home = home,
  take_over_my_home = true,
  daily = home .. '/' .. 'daily',
  weekly = home .. '/' .. 'weekly',
  templates = home .. '/' .. 'templates',
  image_subdir = 'img',
  follow_creates_nonexisting = true,
  dailies_create_nonexisting = true,
  weeklies_create_nonexisting = true,
  media_previewer = 'telescope-media-files',
  new_note_filename = 'title-uuid',
  uuid_type = "%Y-%m-%d",
  uuid_sep = " ",
  image_link_style = 'markdown',
  template_new_note = home .. '/' .. 'templates' .. '/' .. 'new-note.md',
  template_new_daily = home .. '/' .. 'templates' .. '/'.. 'daily.md',
  template_new_weekly = home .. '/' .. 'templates' .. '/'.. 'weekly.md',
}

vim.keymap.set('n', '<Leader>nn', telekasten.new_note, { desc = "new note" })
vim.keymap.set('n', '<Leader>nf', telekasten.find_notes, { desc = "find notes" })
vim.keymap.set('n', '<Leader>nw', telekasten.goto_thisweek, { desc = "goto this week's notes" })
vim.keymap.set('n', '<Leader>nd', telekasten.goto_today, { desc = "goto today's notes" })
vim.keymap.set('n', '<Leader>ns', telekasten.search_notes, { desc = "search notes" })
vim.keymap.set('n', '<Leader>nl', telekasten.insert_link, { desc = "insert note link" })
vim.keymap.set('n', '<Leader>ng', telekasten.follow_link, { desc = "follow note link" })
vim.keymap.set('n', '<Leader>ny', telekasten.yank_notelink, { desc = "yank link to current note" })
vim.keymap.set('n', '<Leader>nt', telekasten.toggle_todo, { desc = "toggle todo in note" })
vim.keymap.set('n', '<Leader>ni', telekasten.insert_img_link, { desc = "insert image link" })
vim.keymap.set('n', '<Leader>np', telekasten.insert_img_link, { desc = "preview image link" })
vim.keymap.set('n', '<Leader>nb', telekasten.insert_img_link, { desc = "browse media" })

-- unmap this as it conflicts with which-key
vim.keymap.set('n', '<Leader>s', '', {})

-- basic vim options
vim.cmd('colorscheme sonokai')
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.linebreak = true
vim.opt.shiftwidth = 4
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.timeoutlen = 250

-- for :Lexplore
vim.g.netrw_altv = 1
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 15

-- I like just having one file for all my neovim configs, so effectively implementing ftplugin here
local function ftplugin(filetype, opts)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetype,
    callback = function()
      for key, value in pairs(opts) do
        vim.opt[key] = value
      end
    end,
  })
end

ftplugin('lua', {
  shiftwidth = 2,
})

ftplugin('markdown', {
  shiftwidth = 2,
  wrap = true,
})

ftplugin('telekasten', {
  shiftwidth = 2,
  textwidth = 80,
  wrap = true,
})

ftplugin('asciidoc', {
  formatoptions = 'tcqr',
  shiftwidth = 2,
  wrap = true,
})
