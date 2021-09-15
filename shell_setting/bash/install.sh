#!/usr/bin/env bash


# .bashrc設定
BASHRC=~/.bashrc
# 相対パスにする
sed -i -e "/PS1=/s/\\\w\\\/\\\W\\\/" $BASHRC


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
  mv $BASH_ALIASES ${BASH_ALIASES}_${DATE_NOW}
fi
cp ./.bash_aliases ~/


source $BASH_PROFILE
source $BASHRC
source $BASH_ALIASES
source $INPUTRC

exit 0
