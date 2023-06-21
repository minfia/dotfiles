#!/usr/bin/env bash



# 指定した権限があるかチェック
# $1-確認したい権限文字列
# 0: 権限あり, 1: 権限なし
function is_auth_in_str()
{
  if groups `whoami` | grep -o " $1 " > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}


# スクリプト実行者にsudo権限があるかチェック
# 0: 権限あり, 1: 権限なし
function is_sudo_auth()
{
  is_auth_in_str "sudo"
  return $?
}

is_sudo_auth
echo $?
