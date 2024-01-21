#!/usr/bin/env bash

. ./lib/generic.sh
. ./lib/package_manager.sh


# アプリケーションインストール先のベースディレクトリ
SYSTEM_BASE_DIR_PATH=${HOME}/.sys

PROGRAM=$(basename $0)


function usage()
{
  echo "Usage: $PROGRAM [Options]..."
  echo "  This script is application and dotfiles installer."
  echo "Options:"
  echo "  -h, --help       show help"
}

# 引数処理
function parse_args()
{
  while [ -n "$1" ]; do

    case $1 in
      -h | --help )
        usage
        exit 0
        ;;
      * )
        usage
        exit 0
        ;;
    esac

    shift
  done
}

function prefix_proc()
{
  :
}

function suffix_proc()
{
  :
}

function install_porg()
{
  # porgインストールチェック
  type porg > /dev/null 2>&1
  if [ $? -eq 0 ] || [ -e ${SYSTEM_BASE_DIR_PATH}/usr/bin/porg ]; then
    # porgがインストール済み
    return 0
  fi

  cd ./app
  ./install_porg.sh
  if [ $? -ne 0 ]; then
    echo "porg install error."
  fi
  if [ -e ./temp ]; then
    rm -rf temp
  fi
  cd ../
  source ~/.bashrc

  return 0
}

function main()
{
  prefix_proc

  install_porg
  if [ $? -ne 0 ]; then
    exit 1
  fi

  suffix_proc
}

parse_args $@

main
