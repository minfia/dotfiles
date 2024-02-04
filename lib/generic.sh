#!/usr/bin/env bash

# ファイルに文字列を書き込む
# すでに書き込まれているかをチェックして、書き込まれていなければ書き込みを行わない
# $1-書き込むファイルパス, $2-書き込む文字列
# 0: 成功, 1: すでに文字列が書き込まれている, 2: 引数エラー, 3: ファイルが存在しない, 4: 書き込む文字列がブランク
function insert_string_in_file()
{
  local WRITE_FILE_PATH=$1
  local WRITE_STR=$2

  if [ $# -ne 2 ]; then
    # echo "missing argument number."
    return 2
  elif [ ! -e ${WRITE_FILE_PATH} ]; then
    # echo "not exist file."
    return 3
  elif [ "${WRITE_STR}" = "" ]; then
    # echo "second argument is blank."
    return 4
  fi

  grep "${WRITE_STR}" "${WRITE_FILE_PATH}" > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    return 1
  fi

  echo -e "${WRITE_STR}" >> ${WRITE_FILE_PATH}

  return 0
}

# 指定した権限をユーザーが持っているか確認
# $1-確認したい権限文字列
# 0: 権限あり, 1: 権限なし
function is_auth_in_str()
{
  groups `whoami` | grep -o " $1 " > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

# 配列の中身を逆順にする
# attention: 文字列の場合、間にスペースがあるものは非対応
# $1-配列
function reverse_array()
{
  local ARR=("$@")
  local ARR_SIZE=${#ARR[@]}

  for ((i=0; i<${ARR_SIZE}; i++)); do
    if [ ${i} -ge `expr ${ARR_SIZE} / 2` ]; then
      break
    fi
    TEMP="${ARR[${i}]}"

    ARR[${i}]="${ARR[${ARR_SIZE}-1-${i}]}"
    ARR[${ARR_SIZE}-1-${i}]="${TEMP}"
  done

  echo ${ARR[@]}
}

# 指定のファイル/ディレクトリを現在時間でバックアップファイル/ディレクトリにする
# $1-バックアップするファイル/ディレクトリのパス
# 現在時間: バックアップ実施, 1: バックアップ未実施
function make_backup_obj()
{
  local OBJ_PATH="$1"

  if [ ! -e ${OBJ_PATH} ]; then
    echo "1"
    return
  fi

  local DATE_NOW=`date "+%Y%m%d_%H%M%S"`
  mv ${OBJ_PATH} ${OBJ_PATH}.backup_${DATE_NOW}

  echo ${DATE_NOW}
}

# Error: "文字列"を出力する
# $1-出力する文字列
function print_error()
{
  echo -e "\e[31mERROR:\e[m $@"
}

# WANING: "文字列"を出力する
# $1-出力する文字列
function print_warning()
{
  echo -e "\e[33mERROR:\e[m $@"
}
