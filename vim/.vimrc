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

" adds cs"' to change surrounding quotes to double quotes
Plug 'tpope/vim-surround'

" overwrite default settings
Plug 'tpope/vim-sensible'

" autoclose brackets
Plug 'jiangmiao/auto-pairs'
"Plug 'Townk/vim-autoclose'

" git manager. Adds :Gstatus, :Gcommit, etc. commands
Plug 'tpope/vim-fugitive'

" project manager
" opens file sidebar ^N
Plug 'scrooloose/nerdtree'

" opens open file propmpt by ^P
Plug 'ctrlpvim/ctrlp.vim'

Plug 'lokaltog/vim-easymotion'
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}

" Utils library for other plugins
" What packages depend on it ???
" Plug 'L9'

" fzf integration
" adds :FZF command to open files
Plug 'junegunn/fzf'

" syntax checker
Plug 'scrooloose/syntastic'

" Code completion
" install instructions: https://github.com/Valloric/YouCompleteMe#installation
Plug 'valloric/youcompleteme'

" Press s to enable 2 charactere easymotio
Plug 'easymotion/vim-easymotion'

Plug 'haya14busa/incsearch.vim'

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


let g:EasyMotion_do_mapping = 0 " Disable default eqsymotion mappings"
" s{char}{char} to move to {char}{char}

nmap s <Plug>(easymotion-overwin-f2)

" Replace "Default" search with vim-easymotion
" Not conveinent to use, needs to press enter
" map  / <Plug>(easymotion-sn)
" omap / <Plug>(easymotion-tn)

" Replace default search with vim-incsearch
" Highlight all matches as you type
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" These `n` & `N` mappings are options. You do not have to map `n` & `N` to
" EasyMotion.
" Without these mappings, `n` & `N` works fine. (These mappings just provide
" different highlight method and have some other features )
map  n <Plug>(easymotion-next)
map  N <Plug>(easymotion-prev)

" Case-Insensitive search in easy-motion
let g:EasyMotion_smartcase = 1
