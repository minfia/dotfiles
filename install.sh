#!/usr/bin/env bash

### include shell scripts ###
. ./lib/generic.sh
. ./lib/package_manager.sh
#############################

##### required user configure (variable) #####
# インストールタイプ
TYPE_GIT=0
TYPE_TMUX=1
TYPE_VIM=2
TYPE_NEOVIM=3
TYPE_SHELL=4

SHELL_TYPE_BASH=0


# アプリケーションインストールフラグ配列
IS_INSTALL_APP_LIST[${TYPE_GIT}]=0
IS_INSTALL_APP_LIST[${TYPE_TMUX}]=0
IS_INSTALL_APP_LIST[${TYPE_VIM}]=0
IS_INSTALL_APP_LIST[${TYPE_NEOVIM}]=0

# アプリケーションバージョン表示フラグ配列
IS_SHOW_APP_VER_LIST[${TYPE_GIT}]=0
IS_SHOW_APP_VER_LIST[${TYPE_TMUX}]=0
IS_SHOW_APP_VER_LIST[${TYPE_VIM}]=0
IS_SHOW_APP_VER_LIST[${TYPE_NEOVIM}]=0

# アプリケーションバージョン切り替えフラグ配列
IS_SWITCH_APP_VER_LIST[${TYPE_GIT}]=0
IS_SWITCH_APP_VER_LIST[${TYPE_TMUX}]=0
IS_SWITCH_APP_VER_LIST[${TYPE_VIM}]=0
IS_SWITCH_APP_VER_LIST[${TYPE_NEOVIM}]=0

# アプリケーションバージョン削除フラグ配列
IS_REMOVE_APP_VER_LIST[${TYPE_GIT}]=0
IS_REMOVE_APP_VER_LIST[${TYPE_TMUX}]=0
IS_REMOVE_APP_VER_LIST[${TYPE_VIM}]=0
IS_REMOVE_APP_VER_LIST[${TYPE_NEOVIM}]=0

# 設定インストールフラグ配列
IS_INSTALL_CONF_LIST[${TYPE_GIT}]=0
IS_INSTALL_CONF_LIST[${TYPE_TMUX}]=0
IS_INSTALL_CONF_LIST[${TYPE_VIM}]=0
IS_INSTALL_CONF_LIST[${TYPE_NEOVIM}]=0
IS_INSTALL_CONF_LIST[${TYPE_SHELL}]=0

# shell設定インストールフラグ配列
IS_INSTALL_SHELL_CONF_LIST[${SHELL_TYPE_BASH}]=0


# アプリ名配列
APP_NAME_LIST[${TYPE_GIT}]="git"
APP_NAME_LIST[${TYPE_TMUX}]="tmux"
APP_NAME_LIST[${TYPE_VIM}]="vim"
APP_NAME_LIST[${TYPE_NEOVIM}]="neovim"
APP_NAME_LIST[${TYPE_SHELL}]="shell"

# shell名配列
SHELL_NAME_LIST[${SHELL_TYPE_BASH}]="bash"


# アプリインストール引数配列
INSTALL_APP_ARGS_LIST[${TYPE_GIT}]=""
INSTALL_APP_ARGS_LIST[${TYPE_TMUX}]=""
INSTALL_APP_ARGS_LIST[${TYPE_VIM}]="--enable-python3"
INSTALL_APP_ARGS_LIST[${TYPE_NEOVIM}]=""

# アプリバージョン配列
INSTALL_APP_VER_LIST[${TYPE_GIT}]=""
INSTALL_APP_VER_LIST[${TYPE_TMUX}]=""
INSTALL_APP_VER_LIST[${TYPE_VIM}]=""
INSTALL_APP_VER_LIST[${TYPE_NEOVIM}]=""

# 切り替えるアプリバージョン格納配列
SWITCH_APP_VER_LIST[${TYPE_GIT}]=""
SWITCH_APP_VER_LIST[${TYPE_TMUX}]=""
SWITCH_APP_VER_LIST[${TYPE_VIM}]=""
SWITCH_APP_VER_LIST[${TYPE_NEOVIM}]=""

# 削除するアプリバージョン格納配列
REMOVE_APP_VER_LIST[${TYPE_GIT}]=""
REMOVE_APP_VER_LIST[${TYPE_TMUX}]=""
REMOVE_APP_VER_LIST[${TYPE_VIM}]=""
REMOVE_APP_VER_LIST[${TYPE_NEOVIM}]=""


# アプリケーションインストールフラグ
IS_INSTALL_APP=0
# アプリケーションバージョン表示フラグ
IS_SHOW_APP_VER=0
# アプリケーションバージョン切り替えフラグ
IS_SWITCH_APP_VER=0
# アプリケーションバージョン削除フラグ
IS_REMOVE_APP_VER=0
# 設定インストールフラグ
IS_INSTALL_CONF=0
# 設定ファイルCleanフラグ
IS_CLEAN_CONF=0

# インストール結果格納
RES_STRING="install result:"
##############################################

# アプリケーションインストール先のベースディレクトリ
SYSTEM_BASE_DIR_PATH=${HOME}/.sys


PROGRAM=$(basename $0)

function usage()
{
  echo -e "Usage: $PROGRAM \e[91mCOMMAND1\e[m [\e[93mOPTIONS\e[m [ARG]]..."
  echo -e "  This script is application and dotfiles installer."
  echo -e "\e[91mCOMMAND\e[m:"
  echo -e "  app               install applications"
  echo -e "  show              show installed application version"
  echo -e "  switch            switch installed application version"
  echo -e "  remove            remove installed applications version"
  echo -e "  conf              install dotfiles"
  echo -e "  clean             clean config files"
  echo -e "\e[93mOPTIONS\e[m:"
  echo -e "  --git [VER]      specify git."
  echo -e "                   support command: 'app' 'show' 'switch' 'remove' 'conf'"
  echo -e "                     used command by VER is 'app', 'show', 'switch' and 'remove'"
  echo -e "  --tmux [VER]     specify tmux."
  echo -e "                   support command: 'app' 'show' 'switch' 'remove' 'conf'"
  echo -e "                     used command by VER is 'app', 'show', 'switch' and 'remove'"
  echo -e "  --vim [VER|OPT]  specify vim."
  echo -e "                   support command: 'app' 'show' 'switch' 'remove' 'conf'"
  echo -e "                     used command by VER is 'app', 'show', 'switch' and 'remove'"
  echo -e "                     used command by OPT is 'conf'"
  echo -e "                       support OPT:"
  echo -e "                         no-lang: Not install programing language plugins"
  echo -e "  --neovim [VER]   specify neovim."
  echo -e "                   support command: 'app' 'show' 'switch' 'remove' 'conf'"
  echo -e "                     used command by VER is 'app', 'show', 'switch' and 'remove'"
  echo -e "  --shell <SHELL>  specify shell."
  echo -e "                   support command: 'conf'"
  echo -e "                     used command is 'conf'"
  echo -e "                   support SHELL:"
  echo -e "                     bash"
  echo -e "  --path <PATH>    specify install path (if not exist path to create path)"
  echo -e "                   default:"
  echo -e "                     ${SYSTEM_BASE_DIR_PATH}"
  echo -e "  -h, --help       show help"
  echo -e "\e[93mVER\e[m:"
  echo -e "  what VER supports:"
  echo -e "    tag            use repository tag."
  echo -e "    master         use repository master branch."
}

# 引数処理
function parse_args()
{
  # COMMAND
  case $1 in
    app )
      IS_INSTALL_APP=1
      ;;
    show )
      IS_SHOW_APP_VER=1
      ;;
    switch )
      IS_SWITCH_APP_VER=1
      ;;
    remove )
      IS_REMOVE_APP_VER=1
      ;;
    conf )
      IS_INSTALL_CONF=1
      ;;
    clean )
      IS_CLEAN_CONF=1
      ;;
    * )
      usage
      exit 1
      ;;
  esac
  shift

  while [ -n "$1" ]; do
    case $1 in
      --git )
        if [ ${IS_INSTALL_APP} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          IS_INSTALL_APP_LIST[${TYPE_GIT}]=1
          INSTALL_APP_VER_LIST[${TYPE_GIT}]="$2"
          shift
        elif [ ${IS_SHOW_APP_VER} -eq 1 ]; then
          IS_SHOW_APP_VER_LIST[${TYPE_GIT}]=1
        elif [ ${IS_SWITCH_APP_VER} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]] || [[ "$2" == "" ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          SWITCH_APP_VER_LIST[${TYPE_GIT}]="$2"
          IS_SWITCH_APP_VER_LIST[${TYPE_GIT}]=1
          shift
        elif [ ${IS_REMOVE_APP_VER} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]] || [[ "$2" == "" ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          REMOVE_APP_VER_LIST[${TYPE_GIT}]="$2"
          IS_REMOVE_APP_VER_LIST[${TYPE_GIT}]=1
          shift
        elif [ ${IS_INSTALL_CONF} -eq 1 ]; then
          IS_INSTALL_CONF_LIST[${TYPE_GIT}]=1
        fi
        ;;
      --tmux )
        if [ ${IS_INSTALL_APP} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          IS_INSTALL_APP_LIST[${TYPE_TMUX}]=1
          INSTALL_APP_VER_LIST[${TYPE_TMUX}]="$2"
          shift
        elif [ ${IS_SHOW_APP_VER} -eq 1 ]; then
          IS_SHOW_APP_VER_LIST[${TYPE_TMUX}]=1
        elif [ ${IS_SWITCH_APP_VER} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]] || [[ "$2" == "" ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          SWITCH_APP_VER_LIST[${TYPE_TMUX}]="$2"
          IS_SWITCH_APP_VER_LIST[${TYPE_TMUX}]=1
          shift
        elif [ ${IS_REMOVE_APP_VER} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]] || [[ "$2" == "" ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          REMOVE_APP_VER_LIST[${TYPE_TMUX}]="$2"
          IS_REMOVE_APP_VER_LIST[${TYPE_TMUX}]=1
          shift
        elif [ ${IS_INSTALL_CONF} -eq 1 ]; then
          IS_INSTALL_CONF_LIST[${TYPE_TMUX}]=1
        fi
        ;;
      --vim )
        if [ ${IS_INSTALL_APP} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          IS_INSTALL_APP_LIST[${TYPE_VIM}]=1
          INSTALL_APP_VER_LIST[${TYPE_VIM}]="$2"
          shift
        elif [ ${IS_SHOW_APP_VER} -eq 1 ]; then
          IS_SHOW_APP_VER_LIST[${TYPE_VIM}]=1
        elif [ ${IS_SWITCH_APP_VER} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]] || [[ "$2" == "" ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          SWITCH_APP_VER_LIST[${TYPE_VIM}]="$2"
          IS_SWITCH_APP_VER_LIST[${TYPE_VIM}]=1
          shift
        elif [ ${IS_REMOVE_APP_VER} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]] || [[ "$2" == "" ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          REMOVE_APP_VER_LIST[${TYPE_VIM}]="$2"
          IS_REMOVE_APP_VER_LIST[${TYPE_VIM}]=1
          shift
        elif [ ${IS_INSTALL_CONF} -eq 1 ]; then
          IS_INSTALL_CONF_LIST[${TYPE_VIM}]=1
        fi
        ;;
      --neovim )
        if [ ${IS_INSTALL_APP} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          IS_INSTALL_APP_LIST[${TYPE_NEOVIM}]=1
          INSTALL_APP_VER_LIST[${TYPE_NEOVIM}]="$2"
          shift
        elif [ ${IS_SHOW_APP_VER} -eq 1 ]; then
          IS_SHOW_APP_VER_LIST[${TYPE_NEOVIM}]=1
        elif [ ${IS_SWITCH_APP_VER} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]] || [[ "$2" == "" ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          SWITCH_APP_VER_LIST[${TYPE_NEOVIM}]="$2"
          IS_SWITCH_APP_VER_LIST[${TYPE_NEOVIM}]=1
          shift
        elif [ ${IS_REMOVE_APP_VER} -eq 1 ]; then
          if [[ "$2" =~ ^-+ ]] || [[ "$2" == "" ]]; then
            print_error "'$2' is failure parameter"
            exit 1
          fi
          REMOVE_APP_VER_LIST[${TYPE_NEOVIM}]="$2"
          IS_REMOVE_APP_VER_LIST[${TYPE_NEOVIM}]=1
          shift
        fi
        ;;
      --shell )
        if [ ${IS_INSTALL_CONF} -eq 0 ]; then
          print_error "This option is not support for application"
          exit 1
        fi
        if [[ "$2" =~ ^-+ ]] || [[ "$2" == "" ]]; then
          print_error "'$2' is failure parameter"
          exit 1
        fi
        if [ "$2" == "bash" ]; then
          IS_INSTALL_SHELL_CONF_LIST[${SHELL_TYPE_BASH}]=1
        else
          print_error "'$2' is not support"
          exit 1
        fi
        IS_INSTALL_CONF_LIST[${TYPE_SHELL}]=1
        shift
        ;;
      --path )
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
        usage
        exit 1
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
  source ~/.profile
}


# 結果を出力
# $1-正常(0)/異常(1), $2-出力する文字列
function result_print()
{
  if [ $1 -eq 0 ]; then
    print_success "$2"
  elif [ $1 -eq 1 ]; then
    print_error "$2"
  fi
}

# xstowのインストール処理
# 0: 正常終了, 1: インストール時異常
function install_xstow()
{
  # xstowインストールチェック
  is_installed_app "xstow"
  if [ $? -eq 0 ] || [ -e ${SYSTEM_BASE_DIR_PATH}/usr/bin/xstow ]; then
    # xstowがインストール済み
    return 0
  fi

  cd ./app
  ./install_xstow.sh
  if [ $? -ne 0 ]; then
    if [ -e ./temp ]; then
      rm -rf temp
      cd ../
    fi
    return 1
  fi
  cd ../

  source ~/.profile

  return 0
}

# 指定のアプリのインストール処理
function install_applications()
{
  for ((i=0; i<${#IS_INSTALL_APP_LIST[@]}; i++)); do
    if [ ${IS_INSTALL_APP_LIST[$i]} -eq 1 ]; then
      # インストールパスを引数に追加する
      if [ ! -z ${INSTALL_APP_VER_LIST[$i]} ]; then
        # バージョン指定あり
        if [ "${INSTALL_APP_VER_LIST[$i]}" == "master" ]; then
          # master指定
          INSTALL_APP_ARGS_LIST[$i]="${INSTALL_APP_ARGS_LIST[$i]} --use-master"
        else
          # バージョン指定
          INSTALL_APP_ARGS_LIST[$i]="${INSTALL_APP_ARGS_LIST[$i]} --tag ${INSTALL_APP_VER_LIST[$i]}"
        fi
      fi
      INSTALL_APP_ARGS_LIST[$i]="${INSTALL_APP_ARGS_LIST[$i]} --path "${SYSTEM_BASE_DIR_PATH}""
      install_app "${APP_NAME_LIST[$i]}" "${INSTALL_APP_ARGS_LIST[$i]}"
      local RET_CODE=$?
      RES_STRING="${RES_STRING}\n    `result_print ${RET_CODE} "${APP_NAME_LIST[$i]} install application"`"
    fi
  done
}

# アプリのインストール処理
# $1-アプリ名, $2-インストール引数
# 0: 正常終了, 1: インストール時異常, 2: 引数異常
function install_app()
{
  local APP_NAME="$1"
  local APP_ARGS="$2"

  if [[ "${APP_NAME}" =~ ^-+ ]]; then
    return 2
  fi

  cd ./app
  ./install_${APP_NAME}.sh ${APP_ARGS}
  if [ $? -ne 0 ]; then
    if [ -e ./temp ]; then
      rm -rf temp
      cd ../
      return 1
    fi
  fi
  cd ../

  return 0
}

# 指定のアプリケーションのバージョンを表示
function show_application_version()
{
  for ((i=0; i<${#IS_SHOW_APP_VER_LIST[@]}; i++)); do
    if [ ${IS_SHOW_APP_VER_LIST[$i]} -eq 1 ]; then
      echo -e "\e[93m${APP_NAME_LIST[$i]} version:\e[m"
      show_version "${APP_NAME_LIST[$i]}"
    fi
  done
}

# アプリケーションのバージョンを表示
# $1-アプリ名
# 0: 正常終了, 2: 引数異常
function show_version()
{
  local APP_NAME="$1"

  if [[ "${APP_NAME}" =~ ^-+ ]]; then
    return 2
  fi

  cd ./app
  ./install_${APP_NAME}.sh --show
  cd ../

  return 0
}

# 指定のアプリケーションのバージョンを切り替える
function switch_application_version()
{
  for ((i=0; i<${#IS_SWITCH_APP_VER_LIST[@]}; i++)); do
    if [ ${IS_SWITCH_APP_VER_LIST[$i]} -eq 1 ]; then
      echo -e "\e[93m${APP_NAME_LIST[$i]} version:\e[m"
      switch_version "${APP_NAME_LIST[$i]}" "${SWITCH_APP_VER_LIST[$i]}"
    fi
  done
}

# アプリケーションのバージョンを切り替える
# $1-アプリ名, $2-アプリバージョン
# 0: 正常終了, 2: 引数異常
function switch_version()
{
  local APP_NAME="$1"
  local APP_VER="$2"

  if [[ "${APP_NAME}" =~ ^-+ ]] || [[ "${APP_VER}" =~ ^-+ ]]; then
    return 2
  fi

  cd ./app
  ./install_${APP_NAME}.sh --switch "${APP_VER}"
  cd ../

  return 0
}

# 指定のアプリケーションのバージョンを削除
function remove_application_version()
{
  for ((i=0; i<${#IS_REMOVE_APP_VER_LIST[@]}; i++)); do
    if [ ${IS_REMOVE_APP_VER_LIST[$i]} -eq 1 ]; then
      echo -e "\e[93m${APP_NAME_LIST[$i]} version:\e[m"
      remove_version "${APP_NAME_LIST[$i]}" "${REMOVE_APP_VER_LIST[$i]}"
    fi
  done
}

# アプリケーションのバージョンを削除
# $1-アプリ名, $2-アプリバージョン
# 0: 正常終了, 2: 引数異常
function remove_version()
{
  local APP_NAME="$1"
  local APP_VER="$2"

  if [[ "${APP_NAME}" =~ ^-+ ]] || [[ "${APP_VER}" =~ ^-+ ]]; then
    return 2
  fi

  cd ./app
  ./install_${APP_NAME}.sh --remove "${APP_VER}"
  cd ../
}

# 設定インストール処理
function install_config()
{
  cd ./conf

  for ((i=0; i<${#IS_INSTALL_CONF_LIST[@]}; i++)); do
    if [ ${IS_INSTALL_CONF_LIST[$i]} -eq 1 ]; then
      local SUB_ARG=""
      if [ $i -eq ${TYPE_SHELL} ]; then
        # shell設定
        for ((j=0; j<${#IS_INSTALL_SHELL_CONF_LIST[@]}; j++)); do
          if [ ${IS_INSTALL_SHELL_CONF_LIST[$j]} -eq 1 ]; then
            SUB_ARG="${SHELL_NAME_LIST[$j]}"
            #echo "app: ${APP_NAME_LIST[$i]}, arg: ${SUB_ARG}"
            install_conf "${APP_NAME_LIST[$i]}" "${SUB_ARG}"
            local LOG_STRING="${APP_NAME_LIST[$i]}(${SUB_ARG})"
            RES_STRING="${RES_STRING}\n    `result_print $? "${LOG_STRING} install config"`"
          fi
        done
      else
        #echo "app: ${APP_NAME_LIST[$i]}, arg: ${SUB_ARG}"
        install_conf "${APP_NAME_LIST[$i]}"
        local RET_CODE=$?
        RES_STRING="${RES_STRING}\n    `result_print $? "${APP_NAME_LIST[$i]} install config"`"
        if [ ${APP_NAME_LIST[$i]} == "tmux" ] && [ ${RET_CODE} -eq 0 ]; then
          RES_STRING="${RES_STRING}\n        Prefix+I: plugins install"
          RES_STRING="${RES_STRING}\n        Prefix+U: plugins upgrade"
          RES_STRING="${RES_STRING}\n        Prefix+alt+u: plugins uninstall"
        fi
      fi
    fi
  done

  cd ../
}

# 設定インストール処理
# $1-アプリ名, $2-インストール引数
# 0: 正常終了, 1: インストール時異常, 2: 引数異常
function install_conf()
{
  local APP_NAME="$1"
  local APP_ARGS="$2"

  if [[ "${APP_NAME}" =~ ^-+ ]]; then
    return 2
  fi

  cd ./${APP_NAME}
  ./install.sh ${APP_ARGS}
  if [ $? -ne 0 ]; then
    if [ -e ./temp ]; then
      rm -rf temp
    fi
    cd ../
    return 1
  fi
  cd ../

  return 0
}

# 指定の設定Clean実行
# $1-該当設定
function clean_proc()
{
  local CONF_NAME=$1
  cd ./"${CONF_NAME}"
  ./install.sh --clean
  cd ../
}

# 設定Clean処理
function clean_conf()
{
  cd ./conf

  # Git
  clean_proc "git"
  # tmux
  clean_proc "tmux"
  # vim
  clean_proc "vim"
  # shell(bash)
  clean_proc "shell"

  cd ../
}

function main()
{
  if [ $# -eq 0 ]; then
    usage
    exit 1
  fi

  parse_args $@


  if [ ${IS_INSTALL_APP} -eq 0 ] && [ ${IS_SHOW_APP_VER} -eq 0 ] && \
     [ ${IS_SWITCH_APP_VER} -eq 0 ] && [ ${IS_REMOVE_APP_VER} -eq 0 ] && \
     [ ${IS_INSTALL_CONF} -eq 0 ] && [ ${IS_CLEAN_CONF} -eq 0 ]; then
    usage
    exit 1
  fi

  prefix_proc

  install_xstow
  if [ $? -ne 0 ]; then
    print_error "xstow install application"
    exit 1
  fi

  if [ ${IS_INSTALL_APP} -eq 1 ]; then
    install_applications
  elif [ ${IS_SHOW_APP_VER} -eq 1 ]; then
    show_application_version
  elif [ ${IS_SWITCH_APP_VER} -eq 1 ]; then
    switch_application_version
  elif [ ${IS_REMOVE_APP_VER} -eq 1 ]; then
    remove_application_version
  elif [ ${IS_INSTALL_CONF} -eq 1 ]; then
    install_config
  elif [ ${IS_CLEAN_CONF} -eq 1 ]; then
    clean_conf
  else
    print_error "COMMAND process."
    exit 1
  fi


  suffix_proc

  if [ ${IS_INSTALL_APP} -eq 1 ] || [ ${IS_INSTALL_CONF} -eq 1 ]; then
    echo -e "${RES_STRING}"
  fi

}

main $@
