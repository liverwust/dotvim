set nocompatible

filetype off
set runtimepath+=~/.homesick/repos/dotvim/vim
let g:UltiSnipsSnippetDirectories=[$HOME.'/.homesick/repos/dotvim/vim/UltiSnips']
source ~/.homesick/repos/dotvim/vim-pathogen/autoload/pathogen.vim
" Consider restricted submodules, which should be conditionally loaded
if has("python3")
  execute pathogen#infect('bundle/{}', '~/.homesick/repos/dotvim/{}', '~/.homesick/repos/dotvim/restricted-submodules/vim-ultisnips')
else
  execute pathogen#infect('bundle/{}', '~/.homesick/repos/dotvim/{}')
endif
filetype plugin indent on

set visualbell                 " Use visual bell instead of beeping
set showcmd                    " Show (partial) command in status line
set showmatch                  " Show matching brackets
set ignorecase                 " Do case insensitive matching
set smartcase                  " Do smart case matching
set incsearch                  " Incremental search
set shiftround                 " Round indent to multiple of 'shiftwidth'
set autoindent                 " Copy indent from current line to new line
set ruler                      " Show current file position in lower-right
set splitright                 " :vsplit new window on the right, not left
set backspace=indent,eol,start " Tell backspace to do its job
colorscheme solarized
syntax enable

" https://vi.stackexchange.com/a/3104/25883
if has("unix")
    function! FontSizePlus ()
      let l:gf_size_whole = matchstr(&guifont, '\( \)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole + 1
      let l:new_font_size = ' '.l:gf_size_whole
      let &guifont = substitute(&guifont, ' \d\+$', l:new_font_size, '')
    endfunction
    function! FontSizeMinus ()
      let l:gf_size_whole = matchstr(&guifont, '\( \)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole - 1
      let l:new_font_size = ' '.l:gf_size_whole
      let &guifont = substitute(&guifont, ' \d\+$', l:new_font_size, '')
    endfunction
else
    function! FontSizePlus ()
      let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole + 1
      let l:new_font_size = ':h'.l:gf_size_whole
      let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
    endfunction
    function! FontSizeMinus ()
      let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole - 1
      let l:new_font_size = ':h'.l:gf_size_whole
      let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
    endfunction
endif

" GVim settings
if has("gui_running")
  if has('unix')
    set guifont=DejaVu\ Sans\ Mono\ 13
  elseif has('win32')
    set guifont=DejaVu_Sans_Mono:h13
  endif
  nnoremap <Leader>- :call FontSizeMinus()<CR>
  nnoremap <Leader>+ :call FontSizePlus()<CR>
  nnoremap <Leader>= :call FontSizePlus()<CR>
  set lines=32
  set guioptions-=T
  set guioptions-=m
  set guioptions-=r
  set guioptions-=R
  set guioptions-=L
endif

" macOS settings
if has('mac')
  " https://stackoverflow.com/a/53625973/5265820
  let &t_ZH="\e[3m"
  let &t_ZR="\e[23m"
endif

" Windows settings
if has('win32')
  " Ctrl-V to paste
  inoremap <C-V> <C-R>+
endif

" straight from Vim's map.txt
function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun

" change basic parameters like tabs vs. spaces, width, etc.
function! s:TextParams(hardtab, tabwidth, textwidth)
  if a:hardtab
    let &l:expandtab = 0
  else
    let &l:expandtab = 1
  endif
  let &l:shiftwidth = a:tabwidth
  let &l:softtabstop = a:tabwidth
  let &l:textwidth = a:textwidth
endfunction

augroup Filetypes
  autocmd!
  autocmd FileType text       call <SID>TextParams(1, 8, 72)
  autocmd FileType vim        call <SID>TextParams(0, 2, 0)
  autocmd FileType python     call <SID>TextParams(0, 4, 78)
  autocmd FileType htmldjango call <SID>TextParams(0, 2, 0)
  autocmd FileType html       call <SID>TextParams(0, 2, 0)
  autocmd FileType css        call <SID>TextParams(0, 2, 0)
  autocmd FileType javascript call <SID>TextParams(0, 2, 0)
  autocmd FileType vb         call <SID>TextParams(0, 4, 0)
  autocmd FileType markdown   call <SID>TextParams(0, 2, 72)
  " https://github.com/vim/vim/issues/5880
  " E363 seen when opening markdown or using the square left bracket.
  autocmd FileType markdown   set maxmempattern=100000
  autocmd FileType yaml       call <SID>TextParams(0, 2, 0)
  autocmd FileType yaml       setlocal noautoindent
  autocmd FileType json       call <SID>TextParams(0, 2, 0)
  autocmd FileType json       setlocal formatoptions=tcq2l
  autocmd FileType json       setlocal foldmethod=syntax
  autocmd FileType mermaid    call <SID>TextParams(0, 2, 0)
augroup END

" trailing whitespace is bad, mmkay?
hi def link CustomTrailingSpace Error
augroup NoTrailingSpace
  autocmd!
  autocmd Syntax python syn match CustomTrailingSpace /\s\+$/
augroup END

" https://vi.stackexchange.com/questions/14829/close-multiple-buffers-interactively
function! <SID>InteractiveBufDelete()
  let l:prompt = "Specify buffers to delete: "

  ls | let bufnums = input(l:prompt)
  while strlen(bufnums)
    echo "\n"
    let buflist = split(bufnums)
    for bufitem in buflist
      if match(bufitem, '^\d\+,\d\+$') >= 0
        exec ':' . bufitem . 'bd'
      elseif match(bufitem, '^\d\+$') >= 0
        exec ':bd ' . bufitem
      else
        echohl ErrorMsg | echo 'Not a number or range: ' . bufitem | echohl None
      endif 
    endfor
    ls | let bufnums = input(l:prompt)
  endwhile 

endfunction
nnoremap <silent> <leader>bd :call <SID>InteractiveBufDelete()<CR>

" https://github.com/moll/vim-bbye
nnoremap <Leader>q :Bdelete<CR>

" Quick access to common hard-tab/soft-tab conventions
nnoremap <Leader>t8 :set sw=8<CR>:set sts=8<CR>:set noet<CR>
nnoremap <Leader>s8 :set sw=8<CR>:set sts=8<CR>:set et<CR>
nnoremap <Leader>s4 :set sw=4<CR>:set sts=4<CR>:set et<CR>
nnoremap <Leader>s2 :set sw=2<CR>:set sts=2<CR>:set et<CR>

" CTRL_W o works differently from tmux and results in all windows except
" for the current one being closed; disable it entirely
nnoremap <C-w>o <Nop>
nnoremap <C-w><C-O> <Nop>

" Easy access to vimrc
nnoremap <Leader>sv :source $MYVIMRC<cr>
nnoremap <Leader>ev :e $MYVIMRC<cr>
