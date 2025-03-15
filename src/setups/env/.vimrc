:set term=xterm-256color
:set t_kb=^H
:set t_kD=^?

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
" Fix backspace issues
:fixdel
" Explicitly map the backspace key
:inoremap <BS> <BS>
:inoremap <C-h> <BS>
inoremap <Char-0x07F> <BS>
nnoremap <Char-0x07F> <BS>

" Clear any existing backspace and delete mappings
:silent! iunmap <BS>
:silent! iunmap <C-h>

" Re-map backspace to delete previous character
:inoremap <BS> <Left><Del>
:inoremap <C-h> <Left><Del>

set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif
:set nopaste
:set background=dark
:set number
" Toggle paste mode with F2
:map <F2> :set paste!<CR>
