syntax on

set number
set ruler

set splitbelow
set splitright

set hlsearch
set incsearch

set shiftwidth=4
set tabstop=4

set autoindent
set smartindent

if has('unix')
	autocmd InsertEnter * set cul
	autocmd InsertLeave * set nocul
endif
