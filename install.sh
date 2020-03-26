#!/bin/bash



if [ -e ~/.tmux.conf ]; then
  # 既に.tmux.confが存在する場合は、バックアップをとる
  cp ~/.tmux.conf ~/.tmux.conf.bak
fi

# tmuxの設定をインストール
cp .tmux.conf ~/

echo "tmux setting done!"

