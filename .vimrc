set nocompatible
filetype off
colorscheme material
syntax enable
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set number              " show line numbers
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
set wrap " turn on line wrapping
set colorcolumn=120  "show a column at 80 chars
set tw=120
set fo=cqt
set fo+=t
set wm=0
set ruler
set laststatus=2
set showmode
set title
set visualbell

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
" For Mac/Linux users
call plug#begin('~/.vim/bundle')
map <C-n> :NERDTreeToggle<CR>

"Plug {{{
call plug#begin('~/.vim/plugged')
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-sensible'
Plug 'preservim/nerdtree'
call plug#end()

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
  let NERDTreeIgnore = [ '__pycache__', '\.pyc$', '\.o$', '\.swp', '*\.swp', 'node_modules/' ]
  let NERDTreeShowHidden=1
  let NERDTreeQuitOnOpen=1
