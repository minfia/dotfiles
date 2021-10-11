#!/usr/bin/env bash


. ../lib/package_manager.sh

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
