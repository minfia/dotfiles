# tmux setting
tmuxの設定ファイルのインストール

## 説明
tmuxを快適に使えるように設定を行うファイルを作成し、インストーラーとして提供する。

## インストールに必要な環境
* tmux
* git

## 機能
1. キーバインドの変更
1. ペインの変更
1. ステータスバーの変更

## プラグイン一覧
* [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)
* [tmux-plugins/tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
* [tmux-plugins/tmux-logging](https://github.com/tmux-plugins/tmux-logging)
* [olimorris/tmux-pomodoro-plus](https://github.com/olimorris/tmux-pomodoro-plus)

## インストール
```bash
$ ./install.sh
```

## 設定ファイル/ディレクトリのバックアップ削除
```bash
$ ./install.sh --clean
```
