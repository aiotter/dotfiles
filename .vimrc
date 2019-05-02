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
  call dein#add('Shougo/vimproc.vim', {'build' : 'make'})
  " call dein#add('tomasr/molokai')
  call dein#add('romainl/vim-dichromatic', {'rev': 'wip'})
  call dein#add('nanotech/jellybeans.vim')
  call dein#add('itchyny/lightline.vim')
  call dein#add('bronson/vim-trailing-whitespace')
  call dein#add('Yggdroot/indentLine')
  call dein#add('davidhalter/jedi-vim')
  call dein#add('kevinw/pyflakes-vim')

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

" 未インストールのプラグインがあればインストール
if dein#check_install()
  call dein#install()
endif


" ----- 文字 -----
set fileencoding=utf-8 " 保存時の文字コード
set fileencodings=ucs-boms,utf-8,euc-jp,cp932 " 読み込み時の文字コードの自動判別. 左側が優先される
set fileformats=unix,dos,mac " 改行コードの自動判別. 左側が優先される
set ambiwidth=double " □や○文字が崩れる問題を解決
set showmatch " 閉じカッコ入力時に対応するカッコを強調


" ----- クリップボード -----
if has('vim_starting')
    set clipboard+=unnamed
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
if has('mouse')
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
  return winwidth(0) > s:threshold ? &fileformat : ''
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


" ----- Python -----
let g:pyflakes_prefer_python_version = 3

