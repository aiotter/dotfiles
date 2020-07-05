set encoding=utf-8
scriptencoding utf-8

" dein.vimパッケージマネージャ
" プラグインが実際にインストールされるディレクトリ
let s:dein_dir = expand('~/.cache/dein')
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vim がなければ github から落としてくる
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

" 設定開始
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " パッケージ一覧
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/vimproc.vim', {'build' : 'make'})
  " call dein#add('tomasr/molokai')
  call dein#add('romainl/vim-dichromatic')
  " call dein#add('nanotech/jellybeans.vim')
  call dein#add('itchyny/lightline.vim')
  " call dein#add('bronson/vim-trailing-whitespace')
  call dein#add('Yggdroot/indentLine')
  call dein#add('Raimondi/delimitMate')  " カッコとかを自動で閉じる
  call dein#add('alvan/vim-closetag')  " HTML タグを自動で閉じる
  call dein#add('dense-analysis/ale')
  call dein#add('majutsushi/tagbar')
  call dein#add('ervandew/supertab')
  call dein#add('easymotion/vim-easymotion')
  call dein#add('tpope/vim-fugitive')

  call dein#add('pearofducks/ansible-vim')

  call dein#add('Shougo/deoplete.nvim')
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif
  call dein#add('thinca/vim-quickrun')
  call dein#add('Shougo/vimproc.vim', {'build' : 'make'})
  call dein#add('davidhalter/jedi', {'on_ft': 'python'})
  call dein#add('deoplete-plugins/deoplete-jedi', {'on_ft': 'python'})


  " 設定終了
  call dein#end()
  call dein#save_state()
endif

" 未インストールのプラグインがあればインストール
if dein#check_install()
  call dein#install()
endif

" ----- プラグインの設定 -----
let g:dein#auto_recache = 1

let g:indentLine_setConceal=0

" Avoid conflicting delimitMate with vim-closetag
autocmd FileType html,xhtml,phtml,jsx let b:delimitMate_matchpairs = "(:),[:],{:}"

let g:SuperTabContextDefaultCompletionType = "context"
let g:SuperTabDefaultCompletionType = "<c-n>"

let g:deoplete#enable_at_startup = 1
call deoplete#custom#option('smart_case', v:true)
call deoplete#custom#option('ignore_sources', {
\ '_': ['around']
\})

" let g:ale_sign_error = '⨉'
" let g:ale_sign_warning = '⚠'
let g:ale_echo_msg_format = '[%severity%]% code:% %s (%linter%)'
let g:ale_sign_column_always = 1
let b:ale_linters = 'all'
let g:ale_linters_ignore = {
\ 'python': ['pyflakes', 'pycodestyle']
\ }

let g:gen_tags#ctags_auto_gen = 1

let g:tagbar_autopreview = 1
autocmd VimEnter * nested :call tagbar#autoopen(1)  " 自動起動
set updatetime=500  " スワップファイルへの書き出し頻度 (=tagbar更新頻度)

let g:quickrun_config = {
\ "python": {
\   "outputter/quickfix/errorformat": '%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m'
\ },
\ "_": {
\   "runner": "vimproc",
\   "runner/vimproc/updatetime": 60,
\   "outputter": "error",
\   "outputter/error/success": "buffer",
\   "outputter/error/error": "quickfix",
\   "outputter/buffer/split": ":botright 8sp",
\   "outputter/buffer/close_on_empty": 1,
\   "hook/time/enable": 1
\ }
\}
" QuickRun 実行時のみ Ctrl-C で強制中断
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"

" ----- キーバインド -----
set ttimeoutlen=100  " Esc で Insert -> Normal のモード遷移を高速化

" ノーマルモードで o を入力したときに挿入モードに移らない
" nnoremap o :<C-u>call append(expand('.'), '')<Cr>j

" Leader
let mapleader = "\<Space>"
nnoremap <Leader>f :let &filetype=input('Enter filetype: ')<CR>

" EasyMortion
map ; <Plug>(easymotion-prefix)


" ----- 文字 -----
set fileencoding=utf-8 " 保存時の文字コード
set fileencodings=ucs-boms,utf-8,euc-jp,cp932 " 読み込み時の文字コードの自動判別. 左側が優先される
set fileformats=unix,dos,mac " 改行コードの自動判別. 左側が優先される
set ambiwidth=double " □や○文字が崩れる問題を解決
set showmatch " 閉じカッコ入力時に対応するカッコを強調


" ----- クリップボード -----
if has('nvim')
    set clipboard+=unnamedplus
elseif has('vim_starting')
    set clipboard+=unnamed
endif


" ----- 制御文字の表示 -----
set list
set listchars=tab:▸\ ,eol:↲,extends:»,precedes:«,nbsp:⚋ ",trail:-
autocmd ColorScheme * highlight NonText    ctermbg=NONE ctermfg=238 guibg=NONE guifg=NONE
autocmd ColorScheme * highlight SpecialKey ctermbg=NONE ctermfg=238 guibg=NONE guifg=NONE


" ----- Concealing (構文の非表示化) の設定 -----
" json のダブルクオーテーションなど，視認性を妨げる文字を隠す設定
if has('conceal')
  set conceallevel=1 " 表示する(0), 代理文字（default: スペース）に置換(1), 非表示(2)
  set concealcursor= " 構文を隠すモードの指定．n: normal, v: visual, i: insert, c: command
endif


" ----- タブとインデント (グローバル設定) -----
set expandtab " タブ入力を複数の空白入力に置き換える
set tabstop=4 " 画面上でタブ文字が占める幅
set softtabstop=4 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent " 改行時に前の行のインデントを継続する
set smartindent " 改行時に前の行の構文をチェックし次の行のインデントを増減する
set shiftwidth=4 " smartindentで増減する幅


" ----- 検索 -----
set incsearch " インクリメンタルサーチ. １文字入力毎に検索を行う
set ignorecase " 検索パターンに大文字小文字を区別しない
set smartcase " 検索パターンに大文字を含んでいたら大文字小文字を区別する
set hlsearch " 検索結果をハイライト

" ESCキー2度押しでハイライトの切り替え
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>


" ----- カーソル -----
set whichwrap=b,s,h,l,<,>,[,],~ " カーソルの左右移動で行末から次の行の行頭への移動が可能になる
set number " 行番号を表示
set cursorline " カーソルラインをハイライト
" highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=darkgray
set scrolloff=5 " スクロール時、常に5行先を表示する

" 行が折り返し表示されていた場合、行単位ではなく表示行単位でカーソルを移動する
nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk

" バックスペースキーの有効化
set backspace=indent,eol,start

if has('vim_starting')
    " 挿入モード時に点滅の縦棒タイプのカーソル
    let &t_SI .= "\e[5 q"
    " ノーマルモード時に非点滅のブロックタイプのカーソル
    let &t_EI .= "\e[2 q"
    " 置換モード時に点滅の下線タイプのカーソル
    let &t_SR .= "\e[3 q"
endif

" ----- コマンド -----
set wildmenu " コマンドモードの補完
set history=5000 " 保存するコマンド履歴の数


" ----- マウス -----
" マウスでカーソル移動やスクロール移動
if has('nvim')
    set mouse=a
elseif has('mouse')
    set mouse=a
    if has('mouse_sgr')
        set ttymouse=sgr
    elseif v:version > 703 || v:version is 703 && has('patch632')
        set ttymouse=sgr
    else
        set ttymouse=xterm2
    endif
endif


" ----- 色 -----
" Colorscheme
if dein#tap('vim-dichromatic')
    colorscheme dichromatic
endif
set t_Co=256
syntax enable


" ----- ステータスライン -----
set laststatus=2 " ステータスラインを常に表示
set noshowmode " 現在のモードを非表示
set showcmd " 打ったコマンドをステータスラインの下に表示
set ruler " ステータスラインの右側にカーソルの現在位置を表示する

let g:lightline = {
      \ 'component_function': {
      \   'fileformat': 'LightlineFileformat',
      \   'fileencoding': 'LightlineFileencoding',
      \   'filetype': 'LightlineFiletype',
      \ },
      \ }

" レスポンシブ対応
let s:threshold = 65
function! LightlineFileformat()
  if winwidth(0) > s:threshold
    return &fileformat ==# 'dos' ? 'CRLF' :
      \ &fileformat ==# 'unix' ? 'LF' :
      \ &fileformat ==# 'mac' ? 'CR' :
      \ &fileformat
  else
    return ''
  endif
endfunction
function! LightlineFileencoding()
  return winwidth(0) > s:threshold ? &fileencoding : ''
endfunction
function! LightlineFiletype()
  return winwidth(0) > s:threshold ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction


" ----- ファイルタイプ固有の設定 -----
filetype plugin indent on
" sw=softtabstop  タブ文字を何文字で表示するか
" sts=shiftwidth  入力したタブ文字を空白何文字に置換するか
" ts=tabstop      自動インデントは空白何文字を用いるか
" et=expandtab    ソフトタブを使用 (タブ文字を空白に置換)
autocmd FileType sh          setlocal sw=2 sts=2 ts=2 et
autocmd FileType zsh         setlocal sw=2 sts=2 ts=2 et
autocmd FileType html        setlocal sw=2 sts=2 ts=2 et
autocmd FileType css         setlocal sw=2 sts=2 ts=2 et
autocmd FileType javascript  setlocal sw=2 sts=2 ts=2 et
autocmd FileType yaml        setlocal sw=2 sts=2 ts=2 et


" ----- 補完 -----
" 常に補完候補を表示/補完ウィンドウ表示時に挿入しない
set completeopt=menuone,noinsert,noselect ",preview

" 補完選択時はEnterで改行をしない
function! _Enter_key()
  if complete_info(['pum_visible', 'selected']) == {'pum_visible': 1, 'selected': -1}
    return "\<CR>\<CR>"
  elseif pumvisible()
    return "\<C-y>"
  else
    return "\<CR>"
  endif
endfunction
inoremap <expr><CR> _Enter_key()

" C-p と C-n を矢印キーと同じ挙動に（候補選択時に挿入しない）
inoremap <expr><C-n> pumvisible() ? "<Down>" : "<C-n>"
inoremap <expr><C-p> pumvisible() ? "<Up>" : "<C-p>"

" カーソルキーで補完ウィンドウにフォーカスしない
function! Is_completion_unforcused()
  return complete_info(['pum_visible', 'selected']) == {'pum_visible': 1, 'selected': -1}
endfunction
inoremap <expr><Down> Is_completion_unforcused() ? "\<C-e>\<Down>" : "\<Down>"
inoremap <expr><Up>   Is_completion_unforcused() ? "\<C-e>\<Up>"   : "\<Up>"


" ----- Python -----
let s:python3_path = $HOME_LOCAL . '/bin/python3'
let s:venv_dir = expand('~/.cache/neovim_venv')

" create venv if not exist
if !isdirectory(s:venv_dir)
  execute '!' . s:python3_path '-m venv' s:venv_dir
endif

" if venv is activated, use it
if exists("$VIRTUAL_ENV")
  let g:python3_host_prog = $VIRTUAL_ENV . '/bin/python'
else
  let g:python3_host_prog = s:venv_dir . '/bin/python'
  " QuickRun のための設定
  let $PATH = s:venv_dir . '/bin:' . $PATH
endif

" Install pynvim
let s:install_pynvim_script = 
  \ "import importlib.util\n"
  \."if importlib.util.find_spec('pynvim') is None:\n"
  \."    import sys, runpy, contextlib\n"
  \."    sys.argv = ['pip', '--disable-pip-version-check', 'install', 'pynvim']\n"
  \."    with contextlib.suppress(SystemExit):\n"
  \."        runpy.run_module('pip', run_name='__main__')"
if has('nvim')
  echo system(g:python3_host_prog . ' -', s:install_pynvim_script)
else
  execute('python3 ' . s:install_pynvim_script)
endif

let g:deoplete#sources#jedi#python_path = g:python3_host_prog
