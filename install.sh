#!/bin/bash



if [ -e ~/.vimrc ]; then
  # 既に.vimrcが存在する場合は、バックアップをとる
  cp ~/.vimrc ~/.vimrc.bak
fi

# vimの設定をインストール
cp .vimrc ~/
cp -r .vim/ ~/
mkdir ~/.vim/plugin

# deinのインストール
if [ ! -d ~/.vim/dein ]; then
  # deinがインストールされていなければインストール
  mkdir ~/.vim/dein
  curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > ./installer.sh
  sh ./installer.sh ~/.vim/dein
  rm -f installer.sh
fi

# Gnu GLOBALのインストール
GGLOBAL_VER=6.6.4
wget http://tamacom.com/global/global-$GGLOBAL_VER.tar.gz
tar zxf global-$GGLOBAL_VER.tar.gz
cd global-$GGLOBAL_VER/
./configure --disable-gtagscscope
make
sudo make install
cp -f ./gtags.vim ~/.vim/plugin/
cd ../
rm -rf global-$GGLOBAL_VER/ global-$GGLOBAL_VER.tar.gz

echo -e "\nvim setting done!"
echo "Please start vim."
echo "After startup, execute ':call dein#install()'."
echo "and 'cd ~/.vim/dein/repos/github.com/iamcco/markdown-preview.nvim/app'"
echo "run to ./install.sh"

