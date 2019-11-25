syntax on
set number
set shiftwidth=4
set tabstop=4
set autoindent
set smartindent
autocmd InsertEnter * set cul
autocmd InsertLeave * set nocul
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/
