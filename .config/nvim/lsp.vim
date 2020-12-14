let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
set completeopt=menuone,noinsert,noselect
lua require'lspconfig'.zls.setup{ on_attach=require'completion'.on_attach }

nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
hi LspDiagnosticsError cterm=NONE ctermfg=black ctermbg=red
hi LspDiagnosticsDefaultError cterm=NONE ctermfg=black ctermbg=red
hi LspDiagnosticsWarning cterm=NONE ctermfg=black ctermbg=yellow
hi LspDiagnosticsDefaultWarning cterm=NONE ctermfg=black ctermbg=yellow
hi LspDiagnosticsInformation cterm=NONE ctermfg=black ctermbg=green
hi LspDiagnosticsDefaultInformation cterm=NONE ctermfg=black ctermbg=green
hi LspDiagnosticsHint cterm=NONE ctermfg=black ctermbg=white
hi LspDiagnosticsDefaultHint cterm=NONE ctermfg=black ctermbg=white
