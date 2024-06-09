#!/usr/bin/env bash

### include shell scripts ###
. ../lib/package_manager.sh
. ../lib/generic.sh
#############################


##### required user configure (variable) #####
# プロジェクトホスティングのユーザ名部分
USER_NAME=neovim

# アプリ名
APP_NAME=neovim

# アプリバージョン
APP_VER=0.9.4
##############################################

### build environment configure (variable) ###
# ビルドに必要なパッケージを指定
PKG_LIST=("ninja-build" "gettext" "cmake" "unzip" "curl")

# makeのターゲット指定
BUILD_TARGET="CMAKE_BUILD_TYPE=Release"

# ./configure時のオプション指定(変数を使用するときは、prefix_make_proc()に記載)
CONFIGURE_OPTIONS=
##############################################

##### required user configure (function) #####
# ./configure前に必要な処理
function prefix_make_proc()
{
  BUILD_TARGET="${BUILD_TARGET} CMAKE_INSTALL_PREFIX=${SYSTEM_BASE_DIR_PATH}/xstow/${ARCHIVE_NAME}"
  return 0
}

# make install後に必要な処理
function suffix_make_proc()
{
  :
  return 0
}

# 固有ヘルプ表示
individual_usage()
{
  :
}

# 固有引数解析
individual_parse_args()
{
  case $1 in
    * )
      usage
      exit 0
      ;;
  esac
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
  echo "  --show        show installed ${APP_NAME} versions"
  echo "  --tag VER     specity repository tag(version)"
  echo "  --switch VER  switch to specific ${APP_NAME} version"
  echo "  --remove VER  remove to specific ${APP_NAME} version"
  echo "  -p, --path    Specify install path. If not exist path to create path."
  echo "                default:"
  echo "                  ${SYSTEM_BASE_DIR_PATH}"
  echo "  -h, --help    show help"
  individual_usage
}

# 引数解析
function parse_args()
{
  while [ -n "$1" ]; do

    case $1 in
      --use-master )
        USE_MASTER_BRANCH=1
        ;;
      --show )
        local VER_LIST=(`get_ver_list`)
        local NOW_VER=`get_now_ver`
        for ((i=0; i<${#VER_LIST[@]}; i++)); do
          local IS_NOW=""
          if [ "${VER_LIST[$i]}" == "${NOW_VER}" ]; then
            IS_NOW="* "
          fi
          echo -e "${IS_NOW}\e[92m${VER_LIST[$i]}\e[m"
        done
        exit 0
        ;;
      --tag )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          print_error "specify install version."
          exit 1
        fi
        APP_VER=$2
        shift
        ;;
      --switch )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          print_error "specify switch version."
          exit 1
        fi
        local NOW_VER=`get_now_ver`
        switch_version "$2"
        local RES=$?
        if [ ${RES} -eq 1 ]; then
          print_error "switch version."
          exit 1
        elif [ ${RES} -eq 2 ]; then
          print_error "$2 is not exist version."
          exit 1
        elif [ ${RES} -eq 3 ]; then
          print_error "specified was the same version."
          exit 1
        else
          print_success "switched ${NOW_VER} to $2"
          exit 0
        fi
        ;;
      --remove )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          print_error "specify remove version."
          exit 1
        fi
        remove_version "$2"
        local RES=$?
        if [ ${RES} -eq 1 ]; then
          print_error "remove version."
          exit 1
        elif [ ${RES} -eq 2 ]; then
          print_error "$2 is not exist version."
          exit 1
        else
          print_success "remove $2."
          exit 0
        fi
        ;;
      -p | --path )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]] || [[ ! "$2" =~ ^/ ]]; then
          # not input string | start charactor '-' | not start charactor '/'
          print_error "specify install path."
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
        individual_parse_args $1
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

# インストール済みのバージョンリストを取得
# 配列(バージョンリスト)
function get_ver_list()
{
  local LIST=(`ls ${SYSTEM_BASE_DIR_PATH}/xstow | grep ^${APP_NAME}`)
  local VER_LIST=${LIST[@]#${APP_NAME}-}
  echo ${VER_LIST[@]}
}

# 使用中のバージョンを取得
# バージョン(文字列)を返す, 見つからない場合は空文字列
function get_now_ver()
{
  local NOW_VER=""
  local APP_REAL_NAME=nvim

  if [ -L ${SYSTEM_BASE_DIR_PATH}/usr/bin/${APP_REAL_NAME} ]; then
    # シンボリックリンクチェック
    local LS_RES=(`ls -l ${SYSTEM_BASE_DIR_PATH}/usr/bin/${APP_REAL_NAME}`)
    local SYMB_STR=${LS_RES[`expr ${#LS_RES[@]} - 1`]}
    local PATH_LIST=(${SYMB_STR//\// })

    for ((i=0; i<${#PATH_LIST[@]}; i++)); do
      if [[ "${PATH_LIST[$i]}" =~ ^"${APP_NAME}-" ]]; then
        NOW_VER=${PATH_LIST[$i]#${APP_NAME}-}
        break
      fi
    done
  fi

  echo "${NOW_VER}"
}

# 指定バージョンへ切り替え
# $1-切り替えるバージョン
# 0: 正常終了, 1: 異常終了, 2: 存在しないバージョン 3: バージョンが同じ
function switch_version()
{
  local VER_LIST=(`get_ver_list`)
  local IS_EXIST_VER=0
  local NOW_VER=`get_now_ver`
  local SW_VER=$1

  if [ "${NOW_VER}" == "${SW_VER}" ]; then
    return 3
  fi

  for ((i=0; i<${#VER_LIST[@]}; i++)); do
    if [ "${VER_LIST[$i]}" == "${SW_VER}" ]; then
      IS_EXIST_VER=1
    fi
  done
  if [ ${IS_EXIST_VER} -ne 1 ]; then
    return 2
  fi

  # シンボリックリンク切り替え処理

  # 現在のバージョンを無効化
  # xstow -D -d prefixで指定したインストール先 -t シンボリックリンク配置先 シンボリックリンク元のディレクトリ名
  xstow -D -d ${SYSTEM_BASE_DIR_PATH}/xstow -t ${SYSTEM_BASE_DIR_PATH}/usr ${APP_NAME}-${NOW_VER}
  if [ $? -ne 0 ]; then
    return 1
  fi

  # 指定されたバージョンを有効化
  # xstow -d prefixで指定したインストール先 -t シンボリックリンク配置先 シンボリックリンク元のディレクトリ名
  xstow -d ${SYSTEM_BASE_DIR_PATH}/xstow -t ${SYSTEM_BASE_DIR_PATH}/usr ${APP_NAME}-${SW_VER}
  if [ $? -ne 0 ]; then
    return 1
  fi

  return 0
}

# 指定バージョンを削除する
# $1-削除するバージョン
# 0: 正常終了, 1: 異常終了, 2: 存在しないバージョン
function remove_version()
{
  local VER_LIST=(`get_ver_list`)
  local IS_EXIST_VER=0
  local NOW_VER=`get_now_ver`
  local DEL_VER=$1

  for ((i=0; i<${#VER_LIST}; i++)); do
    if [ "${VER_LIST[$i]}" == "${DEL_VER}" ]; then
      IS_EXIST_VER=1
      break
    fi
  done
  if [ ${IS_EXIST_VER} -ne 1 ]; then
    return 2
  fi

  # アンインストール処理

  # xstow -D -d prefixで指定したインストール先 -t シンボリックリンク配置先 シンボリックリンク元のディレクトリ名
  if [ "${NOW_VER}" == "${DEL_VER}" ]; then
    # 使用バージョンと指定バージョンが同じ場合は無効化
    xstow -D -d ${SYSTEM_BASE_DIR_PATH}/xstow -t ${SYSTEM_BASE_DIR_PATH}/usr ${APP_NAME}-${DEL_VER}
    if [ $? -ne 0 ]; then
      return 1
    fi
  fi

  # ディレクトリ削除
  rm -rf ${SYSTEM_BASE_DIR_PATH}/xstow/${APP_NAME}-${DEL_VER}
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

  is_installed_app "xstow"
  if [ $? -ne 0 ]; then
    print_error "'xstow' not exist."
    exit 1
  fi

  download_proc
  if [ $? -ne 0 ]; then
    print_error "download process."
    exit 1
  fi

  tar vfx ${ARCHIVE_NAME}.tar.gz
  if [ ${USE_MASTER_BRANCH} -eq 1 ]; then
    local INSTALL_DATE=`date +"%Y%m%d"`
    local MV_NAME=${ARCHIVE_NAME}-${INSTALL_DATE}
    mv ${ARCHIVE_NAME} ${MV_NAME}
    ARCHIVE_NAME=${MV_NAME}
  fi
  cd ${ARCHIVE_NAME}

  prefix_make_proc
  if [ $? -ne 0 ]; then
    print_error "prefix_make_proc."
    exit 1
  fi

  make ${BUILD_TARGET}
  if [ $? -ne 0 ]; then
    print_error "make process."
    exit 1
  fi

  make install
  if [ $? -ne 0 ]; then
    print_error "make install process."
    exit 1
  fi

  # シンボリックリンクを張る
  # xstow -d prefixで指定したインストール先 -t シンボリックリンク配置先 シンボリックリンク元のディレクトリ名
  local IS_INSTALLED=`get_now_ver`
  if [ "${IS_INSTALLED}" == "" ]; then
    xstow -d ${SYSTEM_BASE_DIR_PATH}/xstow -t ${SYSTEM_BASE_DIR_PATH}/usr ${ARCHIVE_NAME}
    if [ $? -ne 0 ]; then
      print_error "xstow registry process."
      exit 1
    fi
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
