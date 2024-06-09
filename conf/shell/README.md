# shell setting
shell周りの設定ファイルのインストール

## 説明
[対応shell](#対応shell)を快適に使えるように設定を行うファイルを作成し、インストーラーとして提供する。

## 対応shell
* bash

## インストールに必要な環境
* bash\
   以下がインストールされていなければ自動でインストールする。
   * bash-completion

## インストール
```bash
$ ./install.sh
```

## 設定ファイル/ディレクトリのバックアップ削除
```bash
$ ./install.sh --clean
```
