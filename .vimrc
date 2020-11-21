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

" Draws horizontal line on insert mode
if has('unix')
	autocmd InsertEnter * set cul
	autocmd InsertLeave * set nocul
endif

" Install vim-plug manager if not installed
if empty(glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Automatically install missing plugins on startup
if !empty(filter(copy(g:plugs), '!isdirectory(v:val.dir)'))
	autocmd VimEnter * PlugInstall | q
endif

Plug 'vim-airline/vim-airline'

call plug#end()

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

