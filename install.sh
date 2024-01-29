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

# porgのインストール処理
# 0: 正常終了, 1: インストール時異常
function install_porg()
{
  # porgインストールチェック
  is_installed_app "porg"
  if [ $? -eq 0 ] || [ -e ${SYSTEM_BASE_DIR_PATH}/usr/bin/porg ]; then
    # porgがインストール済み
    return 0
  fi

  cd ./app
  ./install_porg.sh
  if [ $? -ne 0 ]; then
    echo "porg install error."
    if [ -e ./temp ]; then
      rm -rf temp
      cd ../
      return 1
    fi
  fi
  cd ../
  source ~/.bashrc

  return 0
}

# gitのインストール処理
# 0: 正常終了, 1: インストール時異常
function install_git()
{
  # gitインストールチェック
  is_installed_app "git"
  if [ $? -eq 0 ]; then
    # gitがインストール済み
    return 0
  fi

  cd ./app
  ./install_git.sh
  if [ $? -ne 0 ]; then
    echo "git install error."
    if [ -e ./temp ]; then
      rm -rf temp
      cd ../
      return 1
    fi
  fi
  cd ../

  echo "git install success."

  return 0
}

# tmuxのインストール処理
# 0: 正常終了, 1: インストール時異常
function install_tmux()
{
  # gitインストールチェック
  is_installed_app "tmux"
  if [ $? -eq 0 ]; then
    # tmuxがインストール済み
    return 0
  fi

  cd ./app
  ./install_tmux.sh
  if [ $? -ne 0 ]; then
    echo "tmux install error."
    if [ -e ./temp ]; then
      rm -rf temp
      cd ../
      return 1
    fi
  fi
  cd ../

  echo "tmux install success."

  return 0
}

# vimのインストール処理
# 0: 正常終了, 1: インストール時異常
function install_vim()
{
  # gitインストールチェック
  is_installed_app "vim"
  if [ $? -eq 0 ]; then
    # vimがインストール済み
    return 0
  fi

  cd ./app
  ./install_vim.sh --enable-python3
  if [ $? -ne 0 ]; then
    echo "vim install error."
    if [ -e ./temp ]; then
      rm -rf temp
      cd ../
      return 1
    fi
  fi
  cd ../

  echo "vim install success."

  return 0
}

function main()
{
  prefix_proc

  install_porg
  if [ $? -ne 0 ]; then
    exit 1
  fi

  install_git
  install_tmux
  install_vim

  suffix_proc
}

parse_args $@

main
