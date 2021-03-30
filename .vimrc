" Replace modeで起動することへの対処
set t_u7=
set t_RV=


"# キー入力設定 -----------------------------------------------------------------------------------
" プラグインのキーマップは、プラグイン設定で記入すること
set backspace=indent,eol,start           " Backspaceキーの影響範囲に制限を設けない
set whichwrap=b,s,h,l,<,>,[,]            " 行頭行末の左右移動で行をまたぐ
set scrolloff=5                          " スクロールする際に上下に余裕を持たせる
set sidescrolloff=16                     " スクロールする際に左右に余裕を持たせる
set sidescroll=1                         " 左右スクロールは1文字ずつ行う
let mapleader="\<Space>"                 " LeaderキーをSpaceに設定

"## Normal mode
" xキーで文字を削除したときにヤンクしない
nnoremap x "_x

"### GNU GLOBALの設定
map <C-g> :Gtags
map <C-h> :Gtags -f %<CR>
map <C-j> :GtagsCursor<CR>
map <C-n> :cn<CR>
map <C-p> :cp<CR>

"## Insert mode
" {入力後、Enterで}を自動入力する
" inoremap {<Enter> {}<Left><CR><ESC><S-o>
" [入力後、Enterで]を自動入力する
" inoremap [<Enter> []<Left><CR><ESC><S-o>
" (入力後、Enterで)を自動入力する
" inoremap (<Enter> ()<Left><CR><ESC><S-o>
" Ctrl+hjklでカーソル移動
imap <C-h> <Left>
imap <C-j> <Down>
imap <C-k> <Up>
imap <C-l> <Right>


"# プラグイン設定 ---------------------------------------------------------------------------------
"## deinの設定(カラースキームの設定はこの処理が終わった後に記入する事)
set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim
" プラグインのインストールディレクトリ
let s:dein_dir=expand('~/.vim/dein')
let s:dein_repo_dir=s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " tomlファイル読み込み
  let g:toml_dir=expand('~/.vim/rc')
  let s:toml=g:toml_dir . '/dein.toml'

  " tomlを読み込み、キャッシュ
  call dein#load_toml(s:toml, {'lazy': 0})

  call dein#end()
  call dein#save_state()
endif

" 未インストールのものがあれば、インストールする
if dein#check_install()
  call dein#install()
endif

"# ファイル関係 -----------------------------------------------------------------------------------
"## 文字コード関係
set encoding=utf-8                                         " 文字コード
set fileencoding=utf-8                                     " 保存時の文字コード
set fileencodings=ucs-bom,utf-8,sjis,iso-1022,euc-jp,cp932 " 読み込み時の文字コードを自動判別
set fileformats=unix,dos,mac                               " 改行コードを自動判別

"## インデント関係
set smartindent  " インデントを自動で入れる
set shiftwidth=4 " smartindentで入れるスペース数
set tabstop=4    " タブのスペース数

"## ファイルタイプの設定
filetype on
filetype plugin indent on
autocmd FileType * setlocal tw=0 " 自動改行無効

"## Makefileの設定
let _curfile=expand("%:r") " カレントファイルのファイル名を拡張子抜きで取得
if _curfile == 'Makefile'
    " Makefileの時のみTabを有効にする
    set noexpandtab
else
    set expandtab
endif

"## ファイル上書き前のバックアップ作成の無効化
set nowritebackup
"## スワップファイルを(.swp)を作らない
set noswapfile
"## バックアップファイル(~)を作らない
set nobackup
"## UNDOファイルを(un~)を作らない
set noundofile

"## 前回のカーソル位置記憶
augroup memory_cursor_pos
    autocmd BufRead * if line("'\"") > 0 && line("'\"") <= line("$")
    \ exe "normal g`\"" | endif
augroup END


"# 外見設定 ---------------------------------------------------------------------------------------
scriptencoding utf-8
set title           " タイトル表示
set number          " 行番号表示
set showmatch       " 対応する括弧の強調表示
set cursorline      " カーソルラインの表示
set cmdheight=2     " メッセージ表示欄を2行にする

"## カラースキーム設定↲
syntax on           " 構文ハイライト有効↲
set background=dark " 背景をダークに合わせる↲
↲
""### ポップアップメニューの色設定↲
highlight Pmenu ctermbg=88 ctermfg=white            " メニュー
highlight PmenuSel ctermbg=darkgreen ctermfg=black  " 選択時↲

"## 不可視文字の可視化
set list
set listchars=tab:￫\ ,eol:↲
highlight JpSpace cterm=reverse ctermfg=lightblue gui=reverse guifg=lightblue
autocmd BufRead,BufNew * match JpSpace /　/

"## カーソル表示
if &term =~ "screen"
    let &t_ti.="\eP\e[1 q\e\\"
    let &t_SI.="\eP\e[5 q\e\\"
    let &t_EI.="\eP\e[1 q\e\\"
    let &t_te.="\eP\e[0 q\e\\"
elseif &term =~ "xterm"
    let &t_ti.="\e[1 q"
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
    let &t_te.="\e[0 q"
endif

"## ステータスバー関係
set laststatus=2   " ステータス行を常に表示
"### 左寄せ
set statusline=%f  " ファイル名表示(相対パス)
"set statusline=%F  " ファイル名表示(絶対パス)
set statusline+=%m " 変更チェック表示
set statusline+=%r " 読み取り専用か表示
set statusline+=%w " プレビューウィンドウか表示
"### 右寄せ
set statusline+=%=                 " 右寄せ設定
set statusline+=%{fugitive#statusline()} " Gitブランチ名表示
set statusline+=\ \  " 空白2つ
set statusline+=[%b/0x%B]          " カーソル位置の文字コードを10/16進数表示
set statusline+=\ \  " 空白2つ
set statusline+=[%{&fileformat}]   " ファイルの改行コードを表示
let bom = &bomb ? " BOM" : ""
set statusline+=[%{&fileencoding}%{bom}] " ファイルの文字コードを表示
set statusline+=\ \  " 空白2つ
set statusline+=[%02v:%l/%L]       " カーソル位置の桁数と行列、ファイル全体の行を表示

"# 検索関係 ---------------------------------------------------------------------------------------
set hlsearch   " 検索文字列をハイライトにする
set ignorecase " 大文字と小文字を区別しない
set wrapscan   " 末尾まで検索が終わったら次の検索で先頭に戻る
noremap * *N   " 検索時に次のワードに飛ばさない
noremap # #N   " 検索時に次のワードに飛ばさない

"# クリップボード関係 -----------------------------------------------------------------------------
"  (vimが+clipboardの時のみ有効)
set clipboard+=unnamed
set clipboard+=autoselect

"# その他 -----------------------------------------------------------------------------------------
set mouse=a " マウスを使用可能にする
set nrformats-=octal " 8進数表示を無効化
set history=100 " コマンド履歴の数を変更
set visualbell  " Beep音を消す


