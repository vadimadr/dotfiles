" PORTABLE VIMRC HEADER
" ========================
" set default 'runtimepath' (without ~/.vim folders)
"let &runtimepath = printf('%s/vimfiles,%s,%s/vimfiles/after', $VIM, $VIMRUNTIME, $VIM)

" what is the name of the directory containing this file?
"let s:portable = expand('<sfile>:p:h')
"fasf a

" add the directory to 'runtimepath'
"let &runtimepath = printf('%s,%s,%s/after', s:portable, &runtimepath, s:portable)
" =======================

" download & install vim-plug first:
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

" Install plugins using:
" :PlugInstall

" set nocompatible

" Install plugins using vim-plug
" Plug 'githubuser/repo-name'

let mapleader = ","
call plug#begin()

Plug 'tpope/vim-surround'

" overwrite default settings
Plug 'tpope/vim-sensible'

" autoclose brackets
"Plug 'Townk/vim-autoclose'
Plug 'jiangmiao/auto-pairs'
" git manager
Plug 'tpope/vim-fugitive'
" project manager
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'lokaltog/vim-easymotion'
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}

Plug 'L9'
Plug 'FuzzyFinder'
Plug 'rails.vim'

" syntax checker
Plug 'scrooloose/syntastic'

" Code completion
" install instructions: https://github.com/Valloric/YouCompleteMe#installation
Plug 'valloric/youcompleteme'

call plug#end()

runtime! plugin/sensible.vim

" tab settings
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set number relativenumber autoindent smartindent
syntax on
set noesckeys
set timeoutlen=100

set nocompatible
set clipboard=unnamedplus

map <silent> <C-n> :NERDTreeToggle<CR>
nmap J 25j<cr>
nmap K 25k<cr>
nmap <C-w> :q<cr>
noremap  <silent> <C-s> :update<CR>
noremap <Space> @q
noremap Q @q
