#!/usr/bin/env bash

### include shell scripts ###
. ../../lib/package_manager.sh
. ../../lib/generic.sh
#############################

##### required user configure (variable) #####
# アプリ名
APP_NAME=tmux

# 設定ファイル置き場
CONF_ROOT_PATH=~
##############################################

###### environment configure (variable) ######
# 必要なパッケージを指定
PKG_LIST=()

# 設定ファイル/ディレクトリを指定
CONF_FILE_LIST=(".tmux.conf" ".tmux")
##############################################

##### required user configure (function) #####
# 前に必要な処理
function prefix_proc()
{
  is_installed_app "git"
  if [ $? -ne 0 ]; then
    return 1
  fi

  # tpmのインストール
  git clone https://github.com/tmux-plugins/tpm ${CONF_ROOT_PATH}/.tmux/plugins/tpm

  return 0
}

# 後に必要な処理
function suffix_proc()
{
  :
  return 0
}
##############################################

###### environment configure (function) ######
##############################################


## ここから下は基本ロジックのため安易に変更しない ##

# ヘルプ表示
function usage()
{
  echo "Usage: $(basename $0) [Options]..."
  echo "  This script is '${APP_NAME}' config installer."
  echo "Options:"
  echo "  --clean       delete '${APP_NAME}' config backup files"
  echo "  -h, --help    show help"
}

# 引数解析
function parse_args()
{
  while [ -n "$1" ]; do

    case $1 in
      -h | --help )
        usage
        exit 0
        ;;
      --clean )
        for FL in ${CONF_FILE_LIST[@]}; do
          rm -rf ${CONF_ROOT_PATH}/${FL}.backup_*
        done
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

# 必要なパッケージをインストール
# 0: 正常終了, 1: 管理者権限がない
function install_required_pkgs()
{
  if [ ${#PKG_LIST[@]} -eq 0 ]; then
    return 0
  fi

  local DIST_NAME=`get_distribution`
  local DEF_PKG_MNG_NAME=`get_package_manager ${DIST_NAME}`

  local INSTALL_PKGS=(`get_not_installed_pkgs_from_pkg_mng "${DEF_PKG_MNG_NAME}" "${PKG_LIST[@]}"`)
  if [ ${#INSTALL_PKGS[@]} -eq 0 ]; then
    return 0
  fi

  is_auth_in_str "sudo"
  if [ $? -ne 0 ]; then
    return 1
  fi

  install_from_pkg_mng "${DEF_PKG_MNG_NAME}" "${INSTALL_PKGS[@]}"

  return 0
}

# 設定ファイル/ディレクトリのバックアップを作成
function backup_config()
{
  for BK in "${CONF_FILE_LIST[@]}"; do
    local RES=`make_backup_obj "${CONF_ROOT_PATH}/${BK}"`
  done
}

# 設定ファイル/ディレクトリを設定ファイル置き場コピー
function copy_config_obj()
{
  for FL in "${CONF_FILE_LIST[@]}"; do
    cp -r ${FL} ${CONF_ROOT_PATH}/
  done
}

function main()
{
  is_installed_app "${APP_NAME}"
  if [ $? -ne 0 ]; then
    print_error "${APP_NAME} is not installed."
    exit 1
  fi

  install_required_pkgs
  if [ $? -ne 0 ]; then
    print_error "required package process."
    exit 1
  fi

  backup_config

  prefix_proc
  if [ $? -ne 0 ]; then
    print_error "prefix_proc."
    exit 1
  fi

  copy_config_obj

  suffix_proc
  if [ $? -ne 0 ]; then
    print_error "suffix_proc."
    exit 1
  fi
  suffix_proc

  exit 0
}

parse_args $@

main
