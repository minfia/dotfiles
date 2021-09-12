#!/bin/bash


# alias設定の初期化
function init_alias() {
  if [ "`grep "# user alias setting" $BASHRC`" == "" ]; then
    echo -e "\n# user alias setting" >> $BASHRC
  fi
}

# 指定aliasを追加する
# $1: "alias "を除いたコマンド部分
# ex) add_alias "rm='rm -i'"
function add_alias () {
  CMD_NAME=`echo $1 | sed -e "s/.*='//g" | sed -e "s/ .*'//g"`
  LINE_NUM=`grep "alias $CMD_NAME" -n $BASHRC | sed -e "s/:.*//g"`
  if [ "$LINE_NUM" = "" ]; then
    echo "alias $1" >> $BASHRC
  else
    ALIAS_NAME=`echo $1 | sed -e "s/=.*//g"`
    sed -i -e "/alias $ALIAS_NAME/s/alias $ALIAS_NAME.*/alias $1/" $BASHRC
  fi
}


# .bashrc設定
BASHRC=~/.bashrc
# 相対パスにする
sed -i -e "/PS1=/s/\\\w\\\/\\\W\\\/" $BASHRC

# alias設定
init_alias
add_alias "la='ls -a'"
add_alias "rm='rm -i'"
add_alias "mv='mv -i'"
add_alias "cp='cp -i'"


# .inputrc設定
INPUTRC=~/.inputrc
if [ -e $INPUTRC ]; then
  if [ "`grep "set bell-style none" $INPUTRC`" == "" ]; then
    echo -e "set bell-style none\n" >> $INPUTRC
  fi
else
  echo "set bell-style none" > $INPUTRC
fi

exit 0
