#!/usr/bin/env bash

### include shell scripts ###
. ./lib/generic.sh
. ./lib/package_manager.sh
#############################

##### required user configure (variable) #####
# Gitアプリケーションインストールフラグ
IS_INSTALL_APP_GIT=0
# vimアプリケーションインストールフラグ
IS_INSTALL_APP_VIM=0
# neovimアプリケーションインストールフラグ
IS_INSTALL_APP_NEOVIM=0
# tmuxアプリケーションインストールフラグ
IS_INSTALL_APP_TMUX=0

# Git設定インストールフラグ
IS_INSTALL_CONF_GIT=0
# vim設定インストールフラグ
IS_INSTALL_CONF_VIM=0
# tmux設定インストールフラグ
IS_INSTALL_CONF_TMUX=0
# shell(bash)設定インストールフラグ
IS_INSTALL_CONF_SHELL_BASH=0

# アプリケーションインストールフラグ
IS_INSTALL_APP=0
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
  echo -e "Usage: $PROGRAM \e[91mCOMMAND1\e[m [\e[93mOPTIONS\e[m]... \e[91mCOMMAND2\e[m [\e[93mOPTIONS\e[m]..."
  echo -e "  This script is application and dotfiles installer."
  echo -e "\e[91mCOMMAND\e[m:"
  echo -e "  app               Install application"
  echo -e "  conf              Install dotfile"
  echo -e "\e[93mOPTIONS\e[m:"
  echo -e "  --git             Install git(app/conf)"
  echo -e "  --tmux            Install tmux(app/conf)"
  echo -e "  --vim             Install vim(app/conf)"
  echo -e "  --neovim            Install neovim(app)"
  echo -e "  --shell <SHELL>   Install shell(conf)"
  echo -e "                    support SHELL:"
  echo -e "                      bash"
  echo -e "  --clean           clean config files"
  echo -e "  --path <PATH>     Specify install path. If not exist path to create path."
  echo -e "                    default:"
  echo -e "                      ${SYSTEM_BASE_DIR_PATH}"
  echo -e "  -h, --help        show help"
}

# 引数処理
function parse_args()
{
  while [ -n "$1" ]; do

    case $1 in
      app )
        IS_INSTALL_APP=1
        IS_INSTALL_CONF=0
        ;;
      conf )
        IS_INSTALL_APP=0
        IS_INSTALL_CONF=1
        ;;
      --git )
        if [ ${IS_INSTALL_APP} -eq 1 ]; then
          IS_INSTALL_APP_GIT=1
        elif [ ${IS_INSTALL_CONF} -eq 1 ]; then
          IS_INSTALL_CONF_GIT=1
        fi
        ;;
      --vim )
        if [ ${IS_INSTALL_APP} -eq 1 ]; then
          IS_INSTALL_APP_VIM=1
        elif [ ${IS_INSTALL_CONF} -eq 1 ]; then
          IS_INSTALL_CONF_VIM=1
        fi
        ;;
      --neovim )
        if [ ${IS_INSTALL_APP} -eq 1 ]; then
          IS_INSTALL_APP_NEOVIM=1
        fi
        ;;
      --tmux )
        if [ ${IS_INSTALL_APP} -eq 1 ]; then
          IS_INSTALL_APP_TMUX=1
        elif [ ${IS_INSTALL_CONF} -eq 1 ]; then
          IS_INSTALL_CONF_TMUX=1
        fi
        ;;
      --shell )
        if [ ${IS_INSTALL_APP} -eq 1 ]; then
          print_error "This option is not support for application"
          exit 1
        fi
        if [[ "$2" =~ ^-+ ]] || [[ "$2" == "" ]]; then
          print_error "'$2' is failure parameter"
          exit 1
        fi
        if [ "$2" == "bash" ]; then
          IS_INSTALL_CONF_SHELL_BASH=1
        else
          print_error "'$2' is not support"
          exit 1
        fi
        shift
        ;;
      --clean )
        IS_CLEAN_CONF=1
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

# アプリケーションインストール処理
function install_applications()
{
  if [ ${IS_INSTALL_APP_GIT} -eq 1 ]; then
    install_app_git
    RES_STRING="${RES_STRING}\n    `result_print $? "git install application"`"
  fi

  if [ ${IS_INSTALL_APP_VIM} -eq 1 ]; then
    install_app_vim
    RES_STRING="${RES_STRING}\n    `result_print $? "vim install application"`"
  fi

  if [ ${IS_INSTALL_APP_NEOVIM} -eq 1 ]; then
    install_app_neovim
    RES_STRING="${RES_STRING}\n    `result_print $? "neovim install application"`"
  fi
  if [ ${IS_INSTALL_APP_TMUX} -eq 1 ]; then
    install_app_tmux
    local RET_CODE=$?
    RES_STRING="${RES_STRING}\n    `result_print ${RET_CODE} "tmux install application"`"
    if [ ${RET_CODE} -eq 0 ]; then
      RES_STRING="${RES_STRING}\n        Prefix+I: plugins install"
      RES_STRING="${RES_STRING}\n        Prefix+U: plugins upgrade"
      RES_STRING="${RES_STRING}\n        Prefix+alt+u: plugins uninstall"
    fi
  fi
}

# gitのインストール処理
# 0: 正常終了, 1: インストール時異常, 2: インストール済み
function install_app_git()
{
  cd ./app
  ./install_git.sh --path "${SYSTEM_BASE_DIR_PATH}"
  if [ $? -ne 0 ]; then
    if [ -e ./temp ]; then
      rm -rf temp
      cd ../
    fi
    return 1
  fi
  cd ../

  return 0
}

# vimのインストール処理
# 0: 正常終了, 1: インストール時異常, 2: インストール済み
function install_app_vim()
{
  cd ./app
  ./install_vim.sh --path "${SYSTEM_BASE_DIR_PATH}" --enable-python3
  if [ $? -ne 0 ]; then
    if [ -e ./temp ]; then
      rm -rf temp
      cd ../
    fi
    return 1
  fi
  cd ../

  return 0
}

# neovimのインストール処理
# 0: 正常終了, 1: インストール時異常, 2: インストール済み
function install_app_neovim()
{
  cd ./app
  ./install_neovim.sh --path "${SYSTEM_BASE_DIR_PATH}"
  if [ $? -ne 0 ]; then
    if [ -e ./temp ]; then
      rm -rf temp
      cd ../
    fi
    return 1
  fi
  cd ../

  return 0
}

# tmuxのインストール処理
# 0: 正常終了, 1: インストール時異常, 2: インストール済み
function install_app_tmux()
{
  cd ./app
  ./install_tmux.sh --path "${SYSTEM_BASE_DIR_PATH}"
  if [ $? -ne 0 ]; then
    if [ -e ./temp ]; then
      rm -rf temp
      cd ../
    fi
    return 1
  fi
  cd ../

  return 0
}


# 設定インストール処理
function install_config()
{
  cd ./conf

  if [ ${IS_INSTALL_CONF_GIT} -eq 1 ]; then
    install_conf_git
    RES_STRING="${RES_STRING}\n    `result_print $? "git install config"`"
  fi

  if [ ${IS_INSTALL_CONF_SHELL_BASH} -eq 1 ]; then
    install_conf_shell "bash"
    RES_STRING="${RES_STRING}\n    `result_print $? "shell(bash) install config"`"
  fi

  if [ ${IS_INSTALL_CONF_TMUX} -eq 1 ]; then
    install_conf_tmux
    RES_STRING="${RES_STRING}\n    `result_print $? "tmux install config"`"
  fi

  if [ ${IS_INSTALL_CONF_VIM} -eq 1 ]; then
    install_conf_vim
    RES_STRING="${RES_STRING}\n    `result_print $? "vim install config"`"
  fi

  cd ../
}

# gitの設定インストール処理
# 0: 正常終了, 1: インストール時異常
function install_conf_git()
{
  cd ./git
  ./install.sh
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

# shell(bash)の設定インストール処理
# $1-shellの種類
# 0: 正常終了, 1: インストール時異常
function install_conf_shell()
{
  cd ./shell
  ./install.sh "bash"
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

# tmuxの設定インストール処理
# 0: 正常終了, 1: インストール時異常
function install_conf_tmux()
{
  cd ./tmux
  ./install.sh
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

# vimの設定インストール処理
# 0: 正常終了, 1: インストール時異常
function install_conf_vim()
{
  cd ./vim
  ./install.sh
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
    exit 0
  fi

  parse_args $@

  if [ ${IS_CLEAN_CONF} -eq 1 ]; then
    clean_conf
    exit 0
  fi

  if [ ${IS_INSTALL_APP} -eq 0 ] && [ ${IS_INSTALL_CONF} -eq 0 ]; then
    usage
    exit 1
  fi

  prefix_proc

  install_xstow
  if [ $? -ne 0 ]; then
    print_error "xstow install application"
    exit 1
  fi

  install_applications

  install_config

  suffix_proc

  echo -e "${RES_STRING}"
}

main $@
