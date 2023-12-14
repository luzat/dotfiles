" Do not reconfigure Vim
if v:progname =~? "evim"
  finish
endif

" Use Vim settings
set nocompatible 

" Configure paths
if empty($XDG_CACHE_HOME)
  let $XDG_CACHE_HOME=$HOME . "/.cache"
endif

if empty($XDG_CONFIG_HOME)
  let $XDG_CONFIG_HOME=$HOME . "/.config"
endif

if empty($XDG_DATA_HOME)
  let $XDG_DATA_HOME=$HOME . "/.local/share"
endif

if empty($XDG_STATE_HOME)
  let $XDG_STATE_HOME=$HOME . "/.local/state"
endif

if has('nvim')
  let $VIM_PATH="nvim"
else
  let $VIM_PATH="vim"
endif

function! CreateDirectory (dir)
  if !isdirectory(a:dir)
    call mkdir(a:dir, 'p', '0700')
  endif
endfunction

call CreateDirectory($XDG_STATE_HOME . "/" . $VIM_PATH)

" vim-plug: https://github.com/junegunn/vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')
Plug 'VundleVim/Vundle.vim'
Plug 'ConradIrwin/vim-bracketed-paste' " enable paste mode automatically
Plug 'editorconfig/editorconfig-vim' " .editorconfig support
Plug 'kopischke/vim-fetch' " opening files at :line:column
Plug 'pangloss/vim-javascript'
"Plug 'psliwka/vim-smoothie'
Plug 'tomasr/molokai'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

" Load color scheme
if &term =~ '256color'
  set t_Co=256
  " Disable Background Color Erase (BCE) so that color schemes
  "set t_ut=
endif

" 24-bit true color: neovim 0.1.5+ / vim 7.4.1799+
" enable ONLY if TERM is set valid and it is NOT under mosh
function! IsMosh()
  let output = system('is_mosh -v')
  if v:shell_error
    return 0
  endif
  return !empty(l:output)
endfunction

function! s:auto_termguicolors(...)
  if !(has('termguicolors'))
    return
  endif

  if !IsMosh()
    set termguicolors
  else
    set notermguicolors
  endif
endfunction

if has('termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  " by default, enable 24-bit color, but lazily disable if under mosh
  set termguicolors

  if exists('*timer_start')
    call timer_start(0, function('s:auto_termguicolors'))
  else
    call s:auto_termguicolors()
  endif
endif

"let g:rehash256 = 1
colorscheme molokai
"let g:rehash256 = 1

" Airline setup: https://github.com/vim-airline/vim-airline
let g:airline_powerline_fonts=1
let g:airline_theme='molokai'
let g:airline#extensions#tabline#enabled=1
let g:airline_skip_empty_sections=1
set laststatus=2 " always display status line
set notimeout ttimeout ttimeoutlen=10 " quick timeout on key codes, but not on mappings
set noshowmode

set backspace=indent,eol,start " allow backspacing in insert mode

" swap files
set directory=$XDG_STATE_HOME/$VIM_PATH/swap//
call CreateDirectory($XDG_STATE_HOME . "/" . $VIM_PATH . "/swap")

" keep a backup file (restore to previous version)
set backup 
set backupdir=$XDG_STATE_HOME/$VIM_PATH/backup//,.
call CreateDirectory($XDG_STATE_HOME . "/" . $VIM_PATH . "/backup")

" keep an undo file (undo changes after closing)
if has('persistent_undo')
  set undofile 
  set undodir=$XDG_STATE_HOME/$VIM_PATH/undo//
  call CreateDirectory($XDG_STATE_HOME . "/" . $VIM_PATH . "/undo")
endif

" shared data / viminfo
if !has('nvim')
  set viminfo+=n$XDG_STATE_HOME/$VIM_PATH/viminfo
else
  set shada+=n$XDG_STATE_HOME/$VIM_PATH/shada/main.shada
  call CreateDirectory($XDG_STATE_HOME . "/" . $VIM_PATH . "/shada")
endif

" .netrwhist
let g:netrw_home=$XDG_STATE_HOME . "/" . $VIM_PATH

set history=500 " keep 500 lines of command line history
set wildmenu " display completion matches in a status line
set ruler " show the cursor position all the time
set showcmd " display incomplete commands

set number " show line numbers
set relativenumber " show relative line numbers
set cursorline " highlight current line
set cursorcolumn " highlight current column
set nostartofline " stay in same column
set scrolloff=10 " show lines around cursor

set incsearch " incremental search
set ignorecase " case-insensitive search
set smartcase " except with capital letters

set clipboard=unnamed
set ttyfast
set visualbell " do not beep
set display+=lastline " do not show @@@ in last line if truncated
set nrformats-=octal " do not recognize octal numbers (C-A/C-X)
set confirm " do not fail with unsaved buffers

" no tearoff menu entries in Win32 GUI
if has('win32')
  set guioptions-=t
endif

" Colors (terminal/GUI)?
if &t_Co > 2 || has("gui_running")
  syntax on " syntax highlighting
  set hlsearch " highlight search results
endif

" Don't use Ex mode, use Q for formatting
map Q gq

" C-U in insert mode deletes a lot; use C-G to first break undo,
" so that you can undo C-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Enable mouse
if has('mouse')
  set mouse=a
endif

" Mouse reporting for large terminals
if !has('nvim') && has('mouse_sgr')
  set ttymouse=sgr
endif

" Turn on file type detection, plugin loading and indentation
filetype plugin indent on

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent

if has('autocmd')
  " Revert with:
  " ":augroup vimStartup | au! | augroup END"
  augroup vimStartup
    au!

    " Set line length and indicator column
    autocmd FileType text setlocal textwidth=78
    autocmd FileType gitcommit setlocal textwidth=72
    autocmd FileType gitcommit setlocal colorcolumn+=51
    setlocal colorcolumn=+1

    " Jump to last position when reopening file
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif
  augroup END
endif

" Show difference between file and buffer
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
    \ | wincmd p | diffthis
endif

" The matchit plugin makes the % command work better, but it is not backwards compatible.
if has('syntax') && has('eval')
  packadd! matchit
else
  runtime macros/matchit.vim
endif

" Key mappings
" Delete
imap <C-d> <Del>

" imap <C-a> <Home>
" nmap <C-a> <Home>
" vmap <C-a> <Home>

" imap <C-e> <End>
" nmap <C-e> <End>
" vmap <C-e> <End>

" Save file using sudo
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

nnoremap <C-L> :nohl<CR><C-L> " turn off search highlighting

