#!/usr/bin/env bash


. ../lib/package_manager.sh

check_distribution
echo "The distribution for this system is '$DISTRIBUTOR'."
set_package_management_system_at_distribution $DISTRIBUTOR

if [ -e ~/.w3m ]; then
  DATE_NOW=`date "+%Y%m%d_%H%M%S"`
  # 既に.w3mが存在する場合は、バックアップをとる
  mv ~/.w3m ~/.w3m.backup_$DATE_NOW
fi


# 環境構築に必要なパッケージのインストール
install_pkg $PKG_MNG_SYS "w3m"


# w3mの設定をインストール
cp -r .w3m ~/


exit 0
