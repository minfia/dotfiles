#!/bin/bash


DISTRIBUTOR=
PKG_MNG_SYS=

# パッケージ管理システムでインストール済みかチェック
# $1-対象とするパッケージ管理システム, $2-チェックするパッケージ
# 0: インストール済み, 1: 未インストール
function check_install_pkg()
{
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "argument error."
    exit 1
  fi
  local LIST
  local PKG
  case "$1" in
    "apt" )
      LIST=(`dpkg -l | grep $2`)
      PKG=${LIST[1]}
      ;;
    "pip3" )
      LIST=(`pip3 list --format=columns | grep $2`)
      PKG=${LIST[0]}
      ;;
    * )
      echo "Not supported package management system."
      exit 1
      ;;
  esac

  if [ $PKG = $2 ]; then
    return 0
  else
    return 1
  fi
}

# パッケージ管理システムからパッケージをインストール
# $1-対象とするパッケージ管理システム, $2-インストールするパッケージ
function install_pkg()
{
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "argument error."
    exit 1
  fi
  check_install_pkg $1 $2
  if [ $? -eq 1 ]; then
    echo "install $2"
    # 未インストールならパッケージをインストール
    case "$1" in
      "apt" )
        sudo apt-get install -y $2
        ;;
      "pip3" )
        pip3 install $2
        ;;
      * )
        echo "Not applicable."
        exit 1
        ;;
    esac
  fi
}

# ディストリビューションを確認
function check_distribution()
{
  if command -v lsb_release 2>/dev/null; then
    DISTRIBUTOR=$(lsb_release -a 2>&1 | grep 'Distributor ID' | awk '{print $3}')
  elif [ -e /etc/fedora-release ]; then
    DISTRIBUTOR="Fedora"
  elif [ -e /etc/redhat-release ]; then
    DISTRIBUTOR=$(cat /etc/redhat-release | cut -d ' ' -f 1)
  elif [ -e /etc/arch-release ]; then
    DISTRIBUTOR="Arch"
  elif [ -e /etc/SuSE-release ]; then
    DISTRIBUTOR="SUSE"
  elif [ -e /etc/mandriva-release ]; then
    DISTRIBUTOR="Mandriva"
  elif [ -e /etc/vine-release ]; then
    DISTRIBUTOR="Vine"
  elif [ -e /etc/gentoo-release ]; then
    DISTRIBUTOR="Gentoo"
  else
    DISTRIBUTOR="Unkown"
  fi
}

# ディストリビューションからパッケージ管理システムを設定する
function set_package_management_system_at_distribution()
{
  case "$1" in
    "Ubuntu" )
      PKG_MNG_SYS="apt"
      ;;
    * )
      echo "Not supported distribution and package management system."
      exit 1
      ;;
  esac
}


check_distribution
set_package_management_system_at_distribution $DISTRIBUTOR

if [ -e ~/.vimrc ]; then
  # 既に.vimrcが存在する場合は、バックアップをとる
  cp ~/.vimrc ~/.vimrc.bak
  mv ~/.vim ~/.vim.bak
fi

# vimの設定をインストール
cp .vimrc ~/
cp -r .vim/ ~/
mkdir ~/.vim/plugin

# 環境構築に必要なパッケージのインストール
install_pkg $PKG_MNG_SYS "curl"
install_pkg $PKG_MNG_SYS "wget"
install_pkg $PKG_MNG_SYS "gcc"
install_pkg $PKG_MNG_SYS "make"
install_pkg $PKG_MNG_SYS "libncurses5-dev"
install_pkg $PKG_MNG_SYS "clang-tools"
install_pkg $PKG_MNG_SYS "python3-pip"
install_pkg $PKG_MNG_SYS "python3-venv"
install_pkg "pip3" "python-language-server"

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

