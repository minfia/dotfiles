" Replace modeで起動することへの対処
set t_u7=
set t_RV=


"# キー入力設定 -----------------------------------------------------------------------------------
" プラグインのキーマップは、プラグイン設定で記入すること
"--------------------------------------------------------------------------------------------------"
" Mapping
"--------------------------------------------------------------------------------------------------"
"     コマンド    |                              モード
" 再帰 / 非再帰   | Normal Insert CommandLine Visual Select Operation Terminal Lang-Arg
" map  / noremap  |   @      -         -        @      @        @        -        -
" nmap / nnoremap |   @      -         -        -      -        -        -        -
" map! / noremap! |   -      @         @        -      -        -        -        -
" imap / inoremap |   -      @         -        -      -        -        -        -
" cmap / cnoremap |   -      -         @        -      -        -        -        -
" vmap / vnoremap |   -      -         -        @      @        -        -        -
" xmap / xnoremap |   -      -         -        @      -        -        -        -
" smap / snoremap |   -      -         -        -      @        -        -        -
" omap / onoremap |   -      -         -        -      -        @        -        -
" tmap / tnoremap |   -      -         -        -      -        -        @        -
" lmap / lnoremap |   -      @         @        -      -        -        -        @
"--------------------------------------------------------------------------------------------------"

set backspace=indent,eol,start           " Backspaceキーの影響範囲に制限を設けない
set whichwrap=b,s,h,l,<,>,[,]            " 行頭行末の左右移動で行をまたぐ
set scrolloff=5                          " スクロールする際に上下に余裕を持たせる
set sidescrolloff=16                     " スクロールする際に左右に余裕を持たせる
set sidescroll=1                         " 左右スクロールは1文字ずつ行う
let mapleader="\<Space>"                 " LeaderキーをSpaceに設定
set timeoutlen=200                       " キーマップのキー入力のタイムアウトを200msに設定

"## Normal mode
" xキーで文字を削除したときにヤンクしない
nnoremap x "_x

"### GNU GLOBALの設定
nnoremap <C-g> :Gtags
nnoremap <C-h> :Gtags -f %<CR>
nnoremap <C-j> :GtagsCursor<CR>
nnoremap <C-n> :cn<CR>
nnoremap <C-p> :cp<CR>

"## Insert mode
" {入力後、Enterで}を自動入力する
" inoremap {<Enter> {}<Left><CR><ESC><S-o>
" [入力後、Enterで]を自動入力する
" inoremap [<Enter> []<Left><CR><ESC><S-o>
" (入力後、Enterで)を自動入力する
" inoremap (<Enter> ()<Left><CR><ESC><S-o>
" Ctrl+hjklでカーソル移動
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

"# 独自コマンド -----------------------------------------------------------------------------------------
" vim設定ファイルを開く
command! Config :e $MYVIMRC
" プラグイン設定ファイルのディレクトリを開く
command! Tomls :e ~/.vim/rc

"# プラグイン設定 ---------------------------------------------------------------------------------
let s:jetpackfile="~/.vim/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim"
let s:jetpackurl="https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"
if !filereadable(s:jetpackfile)
  call system(printf('curl -fsSLo %s --create-dirs %s', s:jetpackfile, s:jetpackurl))
endif

" tomlファイルの設定
let s:toml_dir=expand('~/.vim/rc')
let s:pm_toml=s:toml_dir . '/pm.toml'
let s:util_toml=s:toml_dir . '/util.toml'
let s:lsp_toml=s:toml_dir . '/lsp.toml'
let s:toml_toml=s:toml_dir . '/toml.toml'
let s:web_toml=s:toml_dir . '/web.toml'
let s:markdown_toml=s:toml_dir . '/markdown.toml'

" 読み込み
packadd vim-jetpack
call jetpack#begin()
call jetpack#load_toml(s:pm_toml)
call jetpack#load_toml(s:util_toml)
call jetpack#load_toml(s:lsp_toml)
call jetpack#load_toml(s:web_toml)
call jetpack#load_toml(s:markdown_toml)
call jetpack#load_toml(s:toml_toml)
call jetpack#end()

" 未インストールのものがあれば、インストールする
for name in jetpack#names()
  if !jetpack#tap(name)
    call jetpack#sync()
    break
  endif
endfor

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
    autocmd BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
    \ exe "normal g`\"" | endif
augroup END

"## Quickfixのみの場合は、自動で閉じる
augroup quickfix_auto_close
    autocmd!
    autocmd WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&buftype')) == 'quickfix' | quit | endif
augroup END

"## バイナリ編集モード
augroup BinaryXXD
    autocmd!
    autocmd BufReadPre  *.bin let &binary =1
    autocmd BufReadPost * if &binary | silent %!xxd -g 1
    autocmd BufReadPost * set ft=xxd | endif
    autocmd BufWritePre * if &binary | %!xxd -r
    autocmd BufWritePre * endif
    autocmd BufWritePost * if &binary | silent %!xxd -g 1
    autocmd BufWritePost * set nomod | endif
augroup END

"# 外見設定 ---------------------------------------------------------------------------------------
scriptencoding utf-8
set title           " タイトル表示
set showmatch       " 対応する括弧の強調表示
set cursorline      " カーソルラインの表示
set cmdheight=2     " メッセージ表示欄を2行にする

"## カラースキーム設定
syntax on           " 構文ハイライト有効
set background=dark " 背景をダークに合わせる
highlight Constant term=underline ctermfg=203

"### ポップアップメニューの色設定
highlight Pmenu ctermbg=88 ctermfg=white            " メニュー
highlight PmenuSel ctermbg=darkgreen ctermfg=black  " 選択時

"### vimdiffの色設定
highlight DiffAdd cterm=bold ctermfg=15 ctermbg=22
highlight DiffDelete cterm=bold ctermfg=15 ctermbg=52
highlight DiffChange cterm=bold ctermfg=15 ctermbg=33
highlight DiffText cterm=bold ctermfg=33 ctermbg=21

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

"## 行番号設定
" 絶対と相対を表示することでカーソル位置の行のみ絶対行数表示にできる
set number          " 絶対行番号表示
set relativenumber  " 相対行番号表示
" F3で絶対/相対行数表示を切り替える
nnoremap <F3> :<C-u>setlocal relativenumber!<CR>

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
set incsearch  " インクリメンタルサーチを有効にする
set ignorecase " 大文字と小文字を区別しない
set wrapscan   " 末尾まで検索が終わったら次の検索で先頭に戻る

"# クリップボード関係 -----------------------------------------------------------------------------
"  (vimが+clipboardの時のみ有効)
set clipboard+=unnamed
set clipboard+=autoselect

"# その他 -----------------------------------------------------------------------------------------
set mouse=a " マウスを使用可能にする
set nrformats-=octal " 8進数表示を無効化
set history=100 " コマンド履歴の数を変更
set visualbell  " Beep音を消す
" vimの:!コマンド実行でシェルのエイリアスを使えるようにする
if glob("~/.bash_aliases") != ""
    let $BASH_ENV = "~/.bash_aliases"
endif
