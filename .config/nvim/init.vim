call plug#begin()
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'LnL7/vim-nix'
call plug#end()

set path+=**
set wildmenu

" Edit ftplugin file for current file type
com! EditFTPlugin exe 'e ~/.config/nvim/ftplugin/' . &filetype . '.vim'

let g:zig_fmt_fail_silently = 1

colorscheme peachpuff
set number relativenumber expandtab
hi Pmenu cterm=NONE ctermfg=black ctermbg=blue
hi Search ctermfg=black
hi Visual ctermbg=237 ctermfg=none

map <C-J> <C-E>
map <C-K> <C-Y>


runtime lsp.vim
