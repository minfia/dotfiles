#!/usr/bin/env bash

### include shell scripts ###
. ../../lib/package_manager.sh
. ../../lib/generic.sh
#############################

##### required user configure (variable) #####
# アプリ名
APP_NAME=vim

# 設定ファイル置き場
CONF_ROOT_PATH=~
##############################################

###### environment configure (variable) ######
# 必要なパッケージを指定
PKG_LIST=()

# 設定ファイル/ディレクトリを指定
CONF_FILE_LIST=(".vimrc" ".vim")

# 非プログラミング言語関連のみのインストールフラグ
NO_LANG_FLAG=0
##############################################

##### required user configure (function) #####
# 前に必要な処理
function prefix_proc()
{
  is_installed_app "git"
  if [ $? -ne 0 ]; then
    return 1
  fi

  mkdir -p ${CONF_ROOT_PATH}/.vim/plugin

  setup_plugin_manager

  return 0
}

# 後に必要な処理
function suffix_proc()
{
  setup_plugin_list

  # プラグインのインストール
  vim -c ":q!" -c ":q!"

  return 0
}
##############################################

###### environment configure (function) ######
# プラグインマネージャーのセットアップ
function setup_plugin_manager()
{
  curl -fLo ~/.vim/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim
}

# プラグインリストのセットアップ
function setup_plugin_list()
{
  mkdir -p ${CONF_ROOT_PATH}/.vim/rc

  local LANG_TOML_LIST=("lsp.toml" "web.toml" "markdown.toml")
  local EXCLUDE_LIST=
  local COPY_TOML_LIST=

  if [ ${NO_LANG_FLAG} -eq 1 ]; then
    # 除外リスト生成
    for FE in ${LANG_TOML_LIST[@]}; do
      EXCLUDE_LIST=${EXCLUDE_LIST}" -not -name ${FE}"
    done

    # .vimrcで除外するものを編集

    # toml関連
    local DEL_TOML_LIST=${LANG_TOML_LIST[@]//./_}

    local VIMRC=${CONF_ROOT_PATH}/.vimrc
    for DT in ${DEL_TOML_LIST[@]}; do
      local DTNL=`sed -n /${DT}/= ${VIMRC}`
      local DTNL_R=`reverse_array ${DTNL[@]}`
      for DTN in ${DTNL_R[@]}; do
        sed -i ${DTN}d $VIMRC
      done
    done
  fi

  COPY_TOML_LIST=`find ./toml/ -type d -name -prune -o -type f ${EXCLUDE_LIST} -print`
  cp ${COPY_TOML_LIST} ${CONF_ROOT_PATH}/.vim/rc/
}
##############################################


## ここから下は基本ロジックのため安易に変更しない ##

# 追加機能のベースパス
SYSTEM_BASE_DIR_PATH=${HOME}/.sys

# ヘルプ表示
function usage()
{
  echo "Usage: $(basename $0) [Options]..."
  echo "  This script is '${APP_NAME}' config installer."
  echo "Options:"
  echo "  --no-lang     exclude program language"
  echo "  --color       show vim color list"
  echo "  --clean       delete '${APP_NAME}' config backup files"
  echo "  -p, --path    Specify extend system install path. If not exist path to create path."
  echo "                default:"
  echo "                  ${SYSTEM_BASE_DIR_PATH}"
  echo "  -h, --help    show help"
}

# 引数解析
function parse_args()
{
  while [ -n "$1" ]; do

    case $1 in
      --no-lang )
        NO_LANG_FLAG=1
        ;;
      --color )
        ./colorlist.pl
        exit 0
        ;;
      --clean )
        for FL in ${CONF_FILE_LIST[@]}; do
          rm -rf ${CONF_ROOT_PATH}/${FL}.backup_*
        done
        exit 0
        ;;
      -h | --help )
        usage
        exit 0
        ;;
      -p | --path )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]] || [[ ! "$2" =~ ^/ ]]; then
          # not input string | start charactor '-' | not start charactor '/'
          print_error "Specify extend system install path."
          exit 1
        else
          SYSTEM_BASE_DIR_PATH=$2
          shift
        fi
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

  exit 0
}

parse_args $@

main
