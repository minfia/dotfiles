#!/usr/bin/env bash

### include shell scripts ###
. ../lib/package_manager.sh
. ../lib/generic.sh
#############################


##### required user configure (variable) #####
# プロジェクトホスティングのユーザ名部分
USER_NAME=

# アプリ名
APP_NAME=

# アプリバージョン
APP_VER=
##############################################

### build environment configure (variable) ###
# ビルドに必要なパッケージを指定
PKG_LIST=()

# makeのターゲット指定
BUILD_TARGET=

# ./configure時のオプション指定(変数を使用するときは、prefix_make_proc()に記載)
CONFIGURE_OPTIONS=
##############################################

##### required user configure (function) #####
# ./configure前に必要な処理
function prefix_make_proc()
{
  :
  return 0
}

# make install後に必要な処理
function suffix_make_proc()
{
  :
  return 0
}
##############################################

### build environment configure (function) ###
##############################################


## ここから下は基本ロジックのため安易に変更しない ##

# masterブランチを対象にするフラグ
USE_MASTER_BRANCH=0

# インストール先未指定時のベースパス
SYSTEM_BASE_DIR_PATH=${HOME}/.sys

# ヘルプ表示
function usage()
{
  echo "Usage: $(basename $0) [Options]..."
  echo "  This script is '${APP_NAME}' installer."
  echo "Options:"
  echo "  --use-master  application build for master branch"
  echo "  -p, --path    Specify install path. If not exist path to create path."
  echo "                default:"
  echo "                  ${SYSTEM_BASE_DIR_PATH}"

  echo "  -h, --help        show help"
}

# 引数解析
function parse_args()
{
  while [ -n "$1" ]; do

    case $1 in
      --use-master )
        USE_MASTER_BRANCH=1
        ;;
      -p | --path )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]] || [[ ! "$2" =~ ^/ ]]; then
          # not input string | start charactor '-' | not start charactor '/'
          echo "Specify install path error."
          exit 1
        else
          SYSTEM_BASE_DIR_PATH=$2
          shift
        fi
        ;;
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

# ビルドに必要なパッケージをインストール
# 0: 正常終了, 1: 管理者権限がない
function install_required_pkgs()
{
  if [ ${#PKG_LIST[@]} -eq 0 ]; then
    return 0
  fi

  local INSTALL_PKGS=(`get_not_installed_cmds ${PKG_LIST[@]}`)

  if [ ${#INSTALL_PKGS[@]} -eq 0 ]; then
    return 0
  fi

  local DIST_NAME=`get_distribution`
  local DEF_PKG_MNG_NAME=`get_package_manager ${DIST_NAME}`

  is_auth_in_str "sudo"
  if [ $? -ne 0 ]; then
    return 1
  fi

  install_from_pkg "${DEF_PKG_MNG_NAME}" "${INSTALL_PKGS[@]}"

  return 0
}

# アーカイブファイル名
ARCHIVE_NAME=${APP_NAME}

# ビルド対象のアーカイブダウンロード
# 0: 正常終了, 1: ダウンロード失敗
function download_proc()
{
  if [ ${USE_MASTER_BRANCH} -eq 1]; then
    wget https://github.com/${USER_NAME}/${APP_NAME}/archive/master.tar.gz
    if [ $? -ne 0 ]; then
      return 1
    fi
    ARCHIVE_NAME=${ARCHIVE_NAME}-master
    mv master.tar.gz ${ARCHIVE_NAME}.tar.gz
  else
    wget https://github.com/${USER_NAME}/${APP_NAME}/archive/refs/tags/v${APP_VER}.tar.gz
    if [ $? -ne 0 ]; then
      return 1
    fi
    ARCHIVE_NAME=${ARCHIVE_NAME}-${APP_VER}
    mv v${APP_VER} ${ARCHIVE_NAME}.tar.gz
  fi

  return 0
}

# tempディレクトリ名
TEMP_DIR_NAME=temp

function main()
{
  install_required_pkgs
  if [ $? -ne 0 ]; then
    echo "required package error."
    exit 1
  fi

  if [ -e ./${TEMP_DIR_NAME} ]; then
    rm -rf ./${TEMP_DIR_NAME}
  fi
  mkdir ./${TEMP_DIR_NAME}
  cd ${TEMP_DIR_NAME}

  download_proc
  if [ $? -ne 0 ]; then
    echo "download error."
    exit 1
  fi

  tar vfx ${ARCHIVE_NAME}.tar.gz
  cd ${ARCHIVE_NAME}

  prefix_make_proc
  if [ $? -ne 0 ]; then
    echo "prefix_make_proc() error."
    exit 1
  fi

  ./configure --prefix=${SYSTEM_BASE_DIR_PATH}/usr \
              ${CONFIGURE_OPTIONS}

  make ${BUILD_TARGET}
  if [ $? -ne 0 ];then
    echo "make error."
    exit 1
  fi

  if [ ${USE_MASTER_BRANCH} -eq 1 ]; then
    local INSTALL_DATE=`date +"%Y%m%d"`
    porg -lp ${ARCHIVE_NAME}-${INSTALL_DATE} -E/tmp:/dev:/proc:/selinux:/sys:/run:`pwd` "make install"
  else
    porg -lD -E/tmp:/dev:/proc:/selinux:/sys:/run:`pwd` "make install"
  fi

  suffix_make_proc
  if [ $? -ne 0 ]; then
    echo "suffix_make_proc() error."
    exit 1
  fi

  cd ../../
  rm -rf ./${TEMP_DIR_NAME}

  exit 0
}

parse_args $@

main
