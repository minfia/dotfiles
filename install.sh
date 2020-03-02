#!/bin/bash



if [ -e ~/.vimrc ]; then
  # 既に.vimrcが存在する場合は、バックアップをとる
  cp ~/.vimrc ~/.vimrc.bak
fi

# vimの設定をインストール
cp .vimrc ~/
cp -r .vim/ ~/

# deinのインストール
if [ ! -d ~/.vim/dein ]; then
  # deinがインストールされていなければインストール
  mkdir ~/.vim/dein
  curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > ./installer.sh
  sh ./installer.sh ~/.vim/dein
  rm -f installer.sh
fi

echo -e "\nvim setting done!"
echo "Please start vim."
echo "After startup, execute ':call dein#install()'."

