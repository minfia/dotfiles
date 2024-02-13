#!/usr/bin/env bash

### include shell scripts ###
. ../../lib/generic.sh
#############################

##### required user configure (variable) #####
# bash設定ファイルインストールフラグ
INSTALL_BASH_CONF_FLAG=0

# shellファイルのクリーンフラグ
CLEAN_SHELL_CONF_FLAG=0
##############################################

###### environment configure (variable) ######
##############################################

##### required user configure (function) #####
##############################################

###### environment configure (function) ######
##############################################


# ヘルプ表示
function usage()
{
  echo "Usage: $(basename $0) [Options]..."
  echo "  This script is 'shell' config installer."
  echo "Options:"
  echo "  bash          install for bash config file"
  echo "  --clean       delete all 'shell' config backup files"
  echo "  -h, --help    show help"
}

# 引数解析
function parse_args()
{
  while [ -n "$1" ]; do

    case $1 in
      bash )
        INSTALL_BASH_CONF_FLAG=1
        ;;
      -h | --help )
        usage
        exit 0
        ;;
      --clean )
        CLEAN_SHELL_CONF_FLAG=1
        ;;
      * )
        if [[ "$1" =~ ^-+ ]]; then
          usage
        else
          print_error "'$1' unsupported shell type."
        fi
        exit 0
        ;;
    esac

    shift
  done
}

# 引数の数チェック
# $1-引数
# 0: 正常, 1: 異常(即終了)
function argc_check()
{
  if [ $# -ne 1 ]; then
    print_error "argument error."
    exit 1
  fi

  return 0
}

# shell設定ファイルのバックアップファイルを削除
# $1-shell名
function run_shell_conf_clean()
{
  local SHELL_NAME="$1"

  if [ "${SHELL_NAME}" == "" ]; then
    return 1
  fi

  cd ${SHELL_NAME}/
  ./install_conf.sh --clean
  local RET=$?
  cd ../

  return ${RET}
}

# shell設定ファイルインストールスクリプト実行
# $1-shell名
# 0: 正常終了, 1: エラー
function run_install_shell_conf()
{
  local SHELL_NAME="$1"

  if [ "${SHELL_NAME}" == "" ]; then
    return 1
  fi

  cd ${SHELL_NAME}/
  ./install_conf.sh
  local RET=$?
  cd ../

  return ${RET}
}

function main()
{
  if [ ${CLEAN_SHELL_CONF_FLAG} -eq 1 ]; then
    run_shell_conf_clean "bash"
    exit 0
  elif [ ${INSTALL_BASH_CONF_FLAG} -eq 1 ]; then
    run_install_shell_conf "bash"
    local RET=$?
    exit ${RET}
  else
    print_error "error shell conf."
    exit 1
  fi
}

argc_check $@

parse_args $@

main
