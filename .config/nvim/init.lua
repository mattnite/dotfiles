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

  use {
    'pwntester/octo.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = function ()
      require"octo".setup()
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

require"octo".setup({
  default_remote = {"upstream", "origin"}; -- order to try remotes
  ssh_aliases = {},                        -- SSH aliases. e.g. `ssh_aliases = {["github.com-work"] = "github.com"}`
  reaction_viewer_hint_icon = "";         -- marker for user reactions
  user_icon = " ";                        -- user icon
  timeline_marker = "";                   -- timeline marker
  timeline_indent = "2";                   -- timeline indentation
  right_bubble_delimiter = "";            -- bubble delimiter
  left_bubble_delimiter = "";             -- bubble delimiter
  github_hostname = "";                    -- GitHub Enterprise host
  snippet_context_lines = 4;               -- number or lines around commented lines
  issues = {
    order_by = {                           -- criteria to sort results of `Octo issue list`
      field = "CREATED_AT",                -- either COMMENTS, CREATED_AT or UPDATED_AT (https://docs.github.com/en/graphql/reference/enums#issueorderfield)
      direction = "DESC"                   -- either DESC or ASC (https://docs.github.com/en/graphql/reference/enums#orderdirection)
    }
  },
  pull_requests = {
    order_by = {                           -- criteria to sort the results of `Octo pr list`
      field = "CREATED_AT",                -- either COMMENTS, CREATED_AT or UPDATED_AT (https://docs.github.com/en/graphql/reference/enums#issueorderfield)
      direction = "DESC"                   -- either DESC or ASC (https://docs.github.com/en/graphql/reference/enums#orderdirection)
    },
    always_select_remote_on_create = "false" -- always give prompt to select base remote repo when creating PRs
  },
  file_panel = {
    size = 10,                             -- changed files panel rows
    use_icons = true                       -- use web-devicons in file panel (if false, nvim-web-devicons does not need to be installed)
  },
  mappings = {
    issue = {
      close_issue = { lhs = "<space>ic", desc = "close issue" },
      reopen_issue = { lhs = "<space>io", desc = "reopen issue" },
      list_issues = { lhs = "<space>il", desc = "list open issues on same repo" },
      reload = { lhs = "<C-r>", desc = "reload issue" },
      open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
      copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
      add_assignee = { lhs = "<space>aa", desc = "add assignee" },
      remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
      create_label = { lhs = "<space>lc", desc = "create label" },
      add_label = { lhs = "<space>la", desc = "add label" },
      remove_label = { lhs = "<space>ld", desc = "remove label" },
      goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
      add_comment = { lhs = "<space>ca", desc = "add comment" },
      delete_comment = { lhs = "<space>cd", desc = "delete comment" },
      next_comment = { lhs = "]c", desc = "go to next comment" },
      prev_comment = { lhs = "[c", desc = "go to previous comment" },
      react_hooray = { lhs = "<space>rp", desc = "add/remove 🎉 reaction" },
      react_heart = { lhs = "<space>rh", desc = "add/remove ❤️ reaction" },
      react_eyes = { lhs = "<space>re", desc = "add/remove 👀 reaction" },
      react_thumbs_up = { lhs = "<space>r+", desc = "add/remove 👍 reaction" },
      react_thumbs_down = { lhs = "<space>r-", desc = "add/remove 👎 reaction" },
      react_rocket = { lhs = "<space>rr", desc = "add/remove 🚀 reaction" },
      react_laugh = { lhs = "<space>rl", desc = "add/remove 😄 reaction" },
      react_confused = { lhs = "<space>rc", desc = "add/remove 😕 reaction" },
    },
    pull_request = {
      checkout_pr = { lhs = "<space>po", desc = "checkout PR" },
      merge_pr = { lhs = "<space>pm", desc = "merge commit PR" },
      squash_and_merge_pr = { lhs = "<space>psm", desc = "squash and merge PR" },
      list_commits = { lhs = "<space>pc", desc = "list PR commits" },
      list_changed_files = { lhs = "<space>pf", desc = "list PR changed files" },
      show_pr_diff = { lhs = "<space>pd", desc = "show PR diff" },
      add_reviewer = { lhs = "<space>va", desc = "add reviewer" },
      remove_reviewer = { lhs = "<space>vd", desc = "remove reviewer request" },
      close_issue = { lhs = "<space>ic", desc = "close PR" },
      reopen_issue = { lhs = "<space>io", desc = "reopen PR" },
      list_issues = { lhs = "<space>il", desc = "list open issues on same repo" },
      reload = { lhs = "<C-r>", desc = "reload PR" },
      open_in_browser = { lhs = "<C-b>", desc = "open PR in browser" },
      copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
      goto_file = { lhs = "gf", desc = "go to file" },
      add_assignee = { lhs = "<space>aa", desc = "add assignee" },
      remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
      create_label = { lhs = "<space>lc", desc = "create label" },
      add_label = { lhs = "<space>la", desc = "add label" },
      remove_label = { lhs = "<space>ld", desc = "remove label" },
      goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
      add_comment = { lhs = "<space>ca", desc = "add comment" },
      delete_comment = { lhs = "<space>cd", desc = "delete comment" },
      next_comment = { lhs = "]c", desc = "go to next comment" },
      prev_comment = { lhs = "[c", desc = "go to previous comment" },
      react_hooray = { lhs = "<space>rp", desc = "add/remove 🎉 reaction" },
      react_heart = { lhs = "<space>rh", desc = "add/remove ❤️ reaction" },
      react_eyes = { lhs = "<space>re", desc = "add/remove 👀 reaction" },
      react_thumbs_up = { lhs = "<space>r+", desc = "add/remove 👍 reaction" },
      react_thumbs_down = { lhs = "<space>r-", desc = "add/remove 👎 reaction" },
      react_rocket = { lhs = "<space>rr", desc = "add/remove 🚀 reaction" },
      react_laugh = { lhs = "<space>rl", desc = "add/remove 😄 reaction" },
      react_confused = { lhs = "<space>rc", desc = "add/remove 😕 reaction" },
    },
    review_thread = {
      goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
      add_comment = { lhs = "<space>ca", desc = "add comment" },
      add_suggestion = { lhs = "<space>sa", desc = "add suggestion" },
      delete_comment = { lhs = "<space>cd", desc = "delete comment" },
      next_comment = { lhs = "]c", desc = "go to next comment" },
      prev_comment = { lhs = "[c", desc = "go to previous comment" },
      select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
      select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
      close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
      react_hooray = { lhs = "<space>rp", desc = "add/remove 🎉 reaction" },
      react_heart = { lhs = "<space>rh", desc = "add/remove ❤️ reaction" },
      react_eyes = { lhs = "<space>re", desc = "add/remove 👀 reaction" },
      react_thumbs_up = { lhs = "<space>r+", desc = "add/remove 👍 reaction" },
      react_thumbs_down = { lhs = "<space>r-", desc = "add/remove 👎 reaction" },
      react_rocket = { lhs = "<space>rr", desc = "add/remove 🚀 reaction" },
      react_laugh = { lhs = "<space>rl", desc = "add/remove 😄 reaction" },
      react_confused = { lhs = "<space>rc", desc = "add/remove 😕 reaction" },
    },
    submit_win = {
      approve_review = { lhs = "<C-a>", desc = "approve review" },
      comment_review = { lhs = "<C-m>", desc = "comment review" },
      request_changes = { lhs = "<C-r>", desc = "request changes review" },
      close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
    },
    review_diff = {
      add_review_comment = { lhs = "<space>ca", desc = "add a new review comment" },
      add_review_suggestion = { lhs = "<space>sa", desc = "add a new review suggestion" },
      focus_files = { lhs = "<leader>e", desc = "move focus to changed file panel" },
      toggle_files = { lhs = "<leader>b", desc = "hide/show changed files panel" },
      next_thread = { lhs = "]t", desc = "move to next thread" },
      prev_thread = { lhs = "[t", desc = "move to previous thread" },
      select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
      select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
      close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
      toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewer viewed state" },
    },
    file_panel = {
      next_entry = { lhs = "j", desc = "move to next changed file" },
      prev_entry = { lhs = "k", desc = "move to previous changed file" },
      select_entry = { lhs = "<cr>", desc = "show selected changed file diffs" },
      refresh_files = { lhs = "R", desc = "refresh changed files panel" },
      focus_files = { lhs = "<leader>e", desc = "move focus to changed file panel" },
      toggle_files = { lhs = "<leader>b", desc = "hide/show changed files panel" },
      select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
      select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
      close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
      toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewer viewed state" },
    }
  }
})


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

-- extra which-key configs
local wk = require("which-key")
wk.register({
  n = {
    name = "notes",
  }
}, { prefix = "<Leader>" })

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
