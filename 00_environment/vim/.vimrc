" 基本設定
syntax enable
set background=dark
colorscheme hybrid

highlight Normal ctermfg=white ctermbg=black

set laststatus=2
set statusline=%F\ %l:%c\ [%p%%]\ %y
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set expandtab
set autoindent
set formatoptions+=cro
set ruler
set cursorline
set cursorcolumn
" set number

" ファイルを開いたときに前回のカーソル位置を復元
augroup vimrcEx
    autocmd!
    autocmd BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
    \ exe "normal g`\"" | endif
augroup END

" Vimプラグイン管理
call plug#begin()
    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }
    Plug 'morhetz/gruvbox'
call plug#end()

" Markdown の設定は plug#end() の後！
augroup markdown_settings
  autocmd!
  autocmd FileType markdown setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
augroup END

" Markdown プレビュー設定
" Reference
" https://github.com/iamcco/markdown-preview.nvim/tree/master
let g:mkdp_auto_start = 0
let g:mkdp_refresh_slow = 0
let g:mkdp_theme = 'dark'
