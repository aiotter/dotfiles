set encoding=utf-8
scriptencoding utf-8
let mapleader = "\<Space>"


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

  let s:toml_dir  = $HOME . '/.config/nvim/plugins'
  let s:ft_pattern = '\%(/filetype/\)\@<=.\+\%(\.toml$\)\@='  " like s@/filetype/(.*)/.toml$@\1@
  for s:toml in split(globpath(s:toml_dir, '**/*.toml'), '\n')
    let s:option = {}

    " Lazy load plugins in toml named '*.toml'
    if s:toml =~# '_lazy\.toml$'
      let s:option.lazy = 1
    endif

    " Toml placed under '*/filetype/[ft].toml' only loads on the ft
    if s:toml =~# s:ft_pattern
      let s:option.on_ft = matchstr(s:toml, s:ft_pattern)
    endif

    call dein#load_toml(s:toml, s:option)
  endfor

  call dein#end()
  call dein#save_state()
endif

" 未インストールのプラグインがあればインストール
if dein#check_install()
  call dein#install()
endif


" ----- キーバインド -----
set ttimeoutlen=100  " Esc で Insert -> Normal のモード遷移を高速化

" ノーマルモードで o を入力したときに挿入モードに移らない
" nnoremap o :<C-u>call append(expand('.'), '')<Cr>j

" Leader
nnoremap <Leader>f :let &filetype=input('Enter filetype: ')<CR>


" ----- 文字 -----
set fileencoding=utf-8 " 保存時の文字コード
set fileencodings=ucs-boms,utf-8,euc-jp,cp932 " 読み込み時の文字コードの自動判別. 左側が優先される
set fileformats=unix,dos,mac " 改行コードの自動判別. 左側が優先される
" set ambiwidth=double " □や○文字が崩れる問題を解決
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
set tabstop=2 " 画面上でタブ文字が占める幅
set softtabstop=2 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent " 改行時に前の行のインデントを継続する
set smartindent " 改行時に前の行の構文をチェックし次の行のインデントを増減する
set shiftwidth=2 " smartindentで増減する幅


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
set t_Co=256
syntax enable


" ----- フローティングウィンドウ -----
if has('nvim')
  set pumblend=10  " 不透明度
  " set winblend=10
  highlight NormalFloat guifg=#eceff4 guibg=#1e1e1e ctermbg=235
endif


" ----- ステータスライン -----
set laststatus=2 " ステータスラインを常に表示
set noshowmode " 現在のモードを非表示
set showcmd " 打ったコマンドをステータスラインの下に表示
set ruler " ステータスラインの右側にカーソルの現在位置を表示する


" ----- ファイルタイプ固有の設定 -----
filetype plugin indent on
" sw=softtabstop    タブ文字を何文字で表示するか
" sts=shiftwidth    入力したタブ文字を空白何文字に置換するか
" ts=tabstop        自動インデントは空白何文字を用いるか
" et=expandtab      ソフトタブを使用 (タブ文字を空白に置換)
" noet=noexpandtab  ハードタブを使用
autocmd FileType python      setlocal sw=4 sts=4 ts=4 et
autocmd FileType gitconfig   setlocal sw=4 ts=4 noet


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


" ----- その他 -----
" https://vi.stackexchange.com/questions/19953/why-doesnt-this-autocmd-take-effect-for-neovim/19963
set shortmess-=F


" ----- Python -----
let s:python3_path = $HOME_LOCAL . '/bin/python3'
let s:venv_dir = expand('~/.cache/neovim_venv')

" create venv if not exist
if !isdirectory(s:venv_dir)
  execute '!' . s:python3_path '-m venv' s:venv_dir
  execute '!' . s:venv_dir . '/bin/python -m pip --disable-pip-version-check install pynvim'
endif

" if venv is activated, use it
if exists("$VIRTUAL_ENV")
  let g:python3_host_prog = $VIRTUAL_ENV . '/bin/python'
else
  let g:python3_host_prog = s:venv_dir . '/bin/python'
  " QuickRun のための設定
  let $PATH = s:venv_dir . '/bin:' . $PATH
endif

" Ensure pynvim (if not installed, adds sys.path of the venv)
if !has('nvim')
  execute('python3 import importlib.util')
  if py3eval("importlib.util.find_spec('pynvim') is None") == v:true
    let s:venv_sys_path = system(s:venv_dir . '/bin/python -c "import sys; print(sys.path)"')
    execute('python3 sys.path += [p for p in ' . s:venv_sys_path . ' if p.endswith("site-packages")]')
  endif
elseif system(g:python3_host_prog . ' -c "' . "import importlib.util; print(importlib.util.find_spec('pynvim') is None)" . '"') =~ '^True'
  call system(g:python3_host_prog . ' -m pip install pynvim')
endif
