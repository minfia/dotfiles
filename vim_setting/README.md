# vim setting
vimの設定ファイル群  
対応バージョン: 8.2以上

## 説明
vimを快適に使えるように設定を行うファイルを作成し、インストーラーとして提供する。

## 機能
1. 行番号表示
2. タイトル表示
3. カラースキーム
4. インデント
5. カーソルの変更
6. 文字コード
7. 不可視文字の可視化
8. Beep音の無効化
9. プラグインのインストール

## プラグイン一覧
* [Shougo/dein.vim](https://github.com/Shougo/dein.vim)
* [wsdjeg/dein-ui.vim](https://github.com/wsdjeg/dein-ui.vim)
* [tpope/fugitive](https://github.com/tpope/vim-fugitive)
* [tpope/vim-markdown](https://github.com/tpope/vim-markdown)
* [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
* [kannokanno/previm](https://github.com/previm/previm)(会社用)
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
* [GNU GLOBAL](https://www.gnu.org/software/global/)

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

## インストールに必要な環境
以下はインストールされていなければ、自動でインストールする。
* vim
* dein
    * curl
    * git
* GNU Global
    * wget
    * gcc
    * make
    * libncurses5-dev
* Language Server
    * clangd
    * python-language-server
        * python3
        * python3-pip
        * python3-venv

以下は各自でインストールする。
* lsb-release

## インストール
```bash
$ ./install.sh
```

