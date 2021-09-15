#!/usr/bin/env bash


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
      LIST=(`dpkg -l | grep -E "^ii  $2 "`)
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

  if [ "$PKG" = "$2" ]; then
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
    "Ubuntu" | "Debian" )
      PKG_MNG_SYS="apt"
      ;;
    * )
      echo "Not supported distribution and package management system."
      exit 1
      ;;
  esac
}




check_distribution
echo "The distribution for this system is '$DISTRIBUTOR'."
set_package_management_system_at_distribution $DISTRIBUTOR

if [ -e ~/.tmux.conf ]; then
  DATE_NOW=`date "+%Y%m%d_%H%M%S"`
  # 既に.tmux.confが存在する場合は、バックアップをとる
  mv ~/.tmux.conf ~/.tmux.conf.backup_$DATE_NOW
fi


# 環境構築に必要なパッケージのインストール
install_pkg $PKG_MNG_SYS "tmux"
install_pkg $PKG_MNG_SYS "git"


# Tmux Plugin Managerのインストール
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# tmuxの設定をインストール
cp .tmux.conf ~/


exit 0
