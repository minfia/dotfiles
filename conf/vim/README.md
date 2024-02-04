# vim setting
vimの設定ファイルのインストール

## 説明
vimを快適に使えるように設定を行うファイルを作成し、インストーラとして提供する。

## インストールに必要な環境
* vim
* git

## 機能
1. 行番号表示
1. タイトル表示
1. カラースキーム
1. インデント
1. カーソルの変更
1. 文字コード
1. 不可視文字の可視化
1. Beep音の無効化
1. プラグインのインストール

## プラグイン一覧
* [Shougo/dein.vim](https://github.com/Shougo/dein.vim)
* [wsdjeg/dein-ui.vim](https://github.com/wsdjeg/dein-ui.vim)
* [tpope/fugitive](https://github.com/tpope/vim-fugitive)
* [tpope/vim-markdown](https://github.com/tpope/vim-markdown)
* [kannokanno/previm](https://github.com/previm/previm)
* [tyru/open-browser.vim](https://github.com/tyru/open-browser.vim)
* [prabirshrestha/vim-lsp](https://github.com/prabirshrestha/vim-lsp)
* [mattn/vim-lsp-settings](https://github.com/mattn/vim-lsp-settings)
* [prabirshrestha/asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)
* [prabirshrestha/asyncomplete-lsp.vim](https://github.com/prabirshrestha/asyncomplete-lsp.vim)
* [scrooloose/nerdtree](https://github.com/preservim/nerdtree)
* [easymotion/vim-easymotion](https://github.com/easymotion/vim-easymotion)
* [alvan/vim-closetag](https://github.com/alvan/vim-closetag)
* [cespare/vim-toml](https://github.com/cespare/vim-toml)
* [markonm/traces.vim](https://github.com/markonm/traces.vim)
* [thinca/vim-visualstar](https://github.com/thinca/vim-visualstar)
* [Yggdroot/indentLine](https://github.com/Yggdroot/indentLine)
* [skanehira/translate.vim](https://github.com/skanehira/translate.vim)
* [RRethy/vim-illuminate](https://github.com/RRethy/vim-illuminate)
* [t9md/vim-quickhl](https://github.com/t9md/vim-quickhl)
* [liuchengxu/vista.vim](https://github.com/liuchengxu/vista.vim)

## 対応言語
* シェルスクリプト
* C/C++
* Python
* Markdown
* HTML
* CSS

## 対応ファイル形式
* .sh
* .c
* .cpp
* .h
* .hpp
* .py
* .lua
* .css
* .html

## インストール
```bash
# 通常
$ ./install.sh

# 非プログラミング言語のみ
$ ./install.sh --no-lang
```

## vim color一覧
```bash
$ ./install.sh --color
```

## 設定ファイル/ディレクトリのバックアップ削除
```bash
$ ./install.sh --clean
```
