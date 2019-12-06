syntax on
set number
set ruler
set shiftwidth=4
set tabstop=4
set autoindent
set smartindent

if has('unix')
	autocmd InsertEnter * set cul
	autocmd InsertLeave * set nocul
endif

highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/
