#!/usr/bin/env bash


. ../../lib/package_manager.sh

check_distribution
echo "The distribution for this system is '$DISTRIBUTOR'."
set_package_management_system_at_distribution $DISTRIBUTOR

# 環境構築に必要なパッケージのインストール
install_pkg $PKG_MNG_SYS "bash-completion"


# .bashrc設定
BASHRC=~/.bashrc
if [ ! -e $BASHRC ]; then
  cp /etc/skel/.bashrc ~/
fi

if [ -e $BASHRC ]; then
  # 相対パスにする
  sed -i -e "/PS1=/s/\\\w\\\/\\\W\\\/" $BASHRC
fi


# .inputrc設定
INPUTRC=~/.inputrc
if [ -e $INPUTRC ]; then
  if [ "`grep "set bell-style none" $INPUTRC`" == "" ]; then
    echo -e "set bell-style none\n" >> $INPUTRC
  fi
else
  echo -e "set bell-style none" > $INPUTRC
fi

BASH_PROFILE=~/.profile
if [ -e $BASH_PROFILE ]; then
  if  [ "`grep "umask 022" $BASH_PROFILE`" == "" ]; then
    echo -e "umask 022\n" >> $BASH_PROFILE
  elif [ "`grep "#umask 022" $BASH_PROFILE`" != "" ]; then
    sed -i -e "s/^#umask/umask/" $BASH_PROFILE
  fi
else
  echo -e "umask 022" > $BASH_PROFILE
fi

BASH_ALIASES=~/.bash_aliases
if [ -e $BASH_ALIASES ]; then
  DATE_NOW=`date "+%Y%m%d_%H%M%S"`
  # 既に.bash_aliasがある場合は、バックアップを取る
  mv $BASH_ALIASES ${BASH_ALIASES}.backup_${DATE_NOW}
fi
cp ./.bash_aliases ~/


. $BASH_PROFILE
. $BASHRC
. $BASH_ALIASES
. $INPUTRC

exit 0
