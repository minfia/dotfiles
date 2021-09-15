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




# gitで使用するユーザ名/メールアドレス設定
while [ "$KEY" != "y" ]
do
  echo -n "Please input user name: "
  read USER_NAME
  echo -n "Please input user email: "
  read USER_EMAIL

  echo "Is with this confiture alright? (y/n)"
  echo "    user name : $USER_NAME"
  echo "    user email: $USER_EMAIL"
  read -s -n 1 KEY
done


check_distribution
echo "The distribution for this system is '$DISTRIBUTOR'."
set_package_management_system_at_distribution $DISTRIBUTOR

if [ -e ~/.gitconfig ]; then
  DATE_NOW=`date "+%Y%m%d_%H%M%S"`
  # 既に.gitconfigが存在する場合は、バックアップをとる
  mv ~/.gitconfig ~/.gitconfig.backup_$DATE_NOW
fi

if [ -e ~/.gitignore ]; then
  DATE_NOW=`date "+%Y%m%d_%H%M%S"`
  # 既に.gitignoreが存在する場合は、バックアップをとる
  mv ~/.gitignore_global ~/.gitignore_global.backup_$DATE_NOW
fi


# 環境構築に必要なパッケージのインストール
install_pkg $PKG_MNG_SYS "git"


# gitの設定をインストール
cp -r .git* ~/

git config --global user.name "$USER_NAME"
git config --global user.email "$USER_EMAIL"

exit 0
