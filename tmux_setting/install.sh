#!/usr/bin/env bash


. ../lib/package_manager.sh

check_distribution
echo "The distribution for this system is '$DISTRIBUTOR'."
set_package_management_system_at_distribution $DISTRIBUTOR

PPA_LIST=
add_ppa ${PPA_LIST[@]}
if [ $? -eq 1 ]; then
  echo "PPA error"
  exit 1
fi

if [ -e ~/.tmux.conf ]; then
  DATE_NOW=`date "+%Y%m%d_%H%M%S"`
  # 既に.tmux.confが存在する場合は、バックアップをとる
  mv ~/.tmux.conf ~/.tmux.conf.backup_$DATE_NOW
  mv ~/.tmux ~/.tmux.backup_$DATE_NOW
fi


# 環境構築に必要なパッケージのインストール
install_pkg $PKG_MNG_SYS "tmux"
install_pkg $PKG_MNG_SYS "git"


# Tmux Plugin Managerのインストール
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# tmuxの設定をインストール
cp .tmux.conf ~/


exit 0
