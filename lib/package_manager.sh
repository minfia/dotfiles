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

# パッケージ管理システムからパッケージのアップグレード
# $1-対象とするパッケージ管理システム
function upgrade_pkg()
{
  if [ -z "$1" ]; then
    echo "argument error.";
    exit 1
  fi

  case "$1" in
    "apt" )
      sudo apt upgrade -y
      ;;
  esac
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
# $1-ディストリビューション名
function set_package_management_system_at_distribution()
{
  case "$1" in
    "Ubuntu" | "Debian" )
      PKG_MNG_SYS="apt"
      if [ "$1" == "Ubuntu" ]; then
        install_pkg $PKG_MNG_SYS "software-properties-common"
      fi
      ;;
    * )
      echo "Not supported distribution and package management system."
      exit 1
      ;;
  esac
}

# PPAの追加
# $1-追加するリポジトリ(例: ppa:git-core/ppaなら、git-core/ppaの部分)のリスト
# 0: 成功, 1: 失敗 2: ディストリビューションエラー 3: 配列要素なし
function add_ppa()
{
  if [ "$DISTRIBUTOR" != "Ubuntu" ]; then
    return 2
  fi

  local PPA_LIST=($@)
  local PPA_LIST_SIZE=${#PPA_LIST[@]}

  if [ $PPA_LIST_SIZE -eq 0 ]; then
    return 3
  fi

  local PPA_LIST_DIR=/var/lib/apt/lists/
  local PPA_LAUNCHPAD_BASE_NAME=ppa.launchpad.net_
  local ADD_FLG=0

  for ((i=0; i<$PPA_LIST_SIZE; i++)); do
    ls $PPA_LIST_DIR$PPA_LAUNCHPAD_BASE_NAME${PPA_LIST[i]}* > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      sudo add-apt-repository -y ppa:${PPA_LIST[i]}
      ADD_FLG=1
    else
      return 1
    fi
  done

  if [ $ADD_FLG -ne 0 ]; then
    sudo apt update
    upgrade_pkg "apt"
  fi

  return 0
}
