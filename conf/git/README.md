# Git setting
Gitの設定ファイルのインストール

## 説明
Gitを快適に使えるように設定を行うファイルを作成し、インストーラーとして提供する。

## インストールに必要な環境
* git

## 機能
1. ユーザ名とメールアドレスの設定(Global config)
1. デフォルトエディタ
1. デフォルトブランチ名
1. ignoreファイルの指定
1. 文字化け防止
1. difftool設定
1. alias設定

## インストール
```bash
$ ./install.sh
```

## 設定ファイル/ディレクトリのバックアップ削除
```bash
$ ./install.sh --clean
```
