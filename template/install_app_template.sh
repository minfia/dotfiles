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

  echo "  -h, --help    show help"
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
          print_error "Specify install path."
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

# アーカイブファイル名
ARCHIVE_NAME=${APP_NAME}

# ビルド対象のアーカイブダウンロード
# 0: 正常終了, 1: ダウンロード失敗
function download_proc()
{
  # GitHubの非共通部URL
  local URL_SUFFIX=

  if [ ${USE_MASTER_BRANCH} -eq 1 ]; then
    APP_VER=master
    URL_SUFFIX=master.tar.gz
  else
    URL_SUFFIX=refs/tags/v${APP_VER}.tar.gz
  fi

  ARCHIVE_NAME=${ARCHIVE_NAME}-${APP_VER}

  wget -O ${ARCHIVE_NAME}.tar.gz https://github.com/${USER_NAME}/${APP_NAME}/archive/${URL_SUFFIX}
  if [ $? -ne 0 ]; then
    return 1
  fi

  return 0
}

function main()
{
  install_required_pkgs
  if [ $? -ne 0 ]; then
    print_error "required package process."
    exit 1
  fi

  if [ -e ./temp ]; then
    rm -rf temp
  fi
  mkdir ./temp
  cd temp

  is_installed_app "porg"
  if [ $? -ne 0 ]; then
    print_error "'porg' not exist."
    exit 1
  fi

  download_proc
  if [ $? -ne 0 ]; then
    print_error "download process."
    exit 1
  fi

  tar vfx ${ARCHIVE_NAME}.tar.gz
  cd ${ARCHIVE_NAME}

  prefix_make_proc
  if [ $? -ne 0 ]; then
    print_error "prefix_make_proc."
    exit 1
  fi

  ./configure --prefix=${SYSTEM_BASE_DIR_PATH}/usr \
              ${CONFIGURE_OPTIONS}

  make ${BUILD_TARGET}
  if [ $? -ne 0 ];then
    print_error "make process."
    exit 1
  fi

  if [ ${USE_MASTER_BRANCH} -eq 1 ]; then
    local INSTALL_DATE=`date +"%Y%m%d"`
    porg -lp ${APP_NAME}-${INSTALL_DATE}_master -E/tmp:/dev:/proc:/selinux:/sys:/run:`pwd` "make install"
  else
    porg -lD -E/tmp:/dev:/proc:/selinux:/sys:/run:`pwd` "make install"
  fi

  suffix_make_proc
  if [ $? -ne 0 ]; then
    print_error "suffix_make_proc."
    exit 1
  fi

  cd ../../
  rm -rf temp

  exit 0
}

parse_args $@

main
