#!/usr/bin/env bash


PROGRAM=$(basename $0)


function usage()
{
  echo "Usage: $PROGRAM [Options]..."
  echo "  This script is dotfiles installer."
  echo "Options:"
  echo "  --git            install git setting"
  echo "  --shell TYPE     install shell setting"
  echo "  --tmux           install tmux setting"
  echo "  --vim [Option]   install vim setting"
  echo "                   If selected multiple option valid first option"
  echo "                   Option:"
  echo "                     company"
  echo "                     no-lang"
  echo "  --w3m            install w3m setting"
  echo ""
  echo "  --clean          clean backup file(s)"
  echo "  -h, --help       show help"
}


if [ $# -eq 0 ]; then
  usage
  exit 0
fi


FLAG_VIM=0
FLAG_TMUX=0
FLAG_SHELL=0
FLAG_W3M=0
FLAG_GIT=0


VIM_TYPE=
SHELL_TYPE=


function parse_args()
{
  while [ -n "$1" ]
  do
    case $1 in
      --vim )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          FLAG_VIM=1
        elif [[ "$2" == "company" ]]; then
          FLAG_VIM=1
          VIM_TYPE="company"
          shift
        elif [[ "$2" == "no-lang" ]]; then
          FLAG_VIM=1
          VIM_TYPE="no-lang"
        else
          echo "vim install argument error."
          exit 1
        fi
        ;;
      --tmux )
        FLAG_TMUX=1
        ;;
      --shell )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "shell install argument error."
          exit 1
        fi
        SHELL_TYPE=$2
        FLAG_SHELL=1
        shift
        ;;
      --w3m )
        FLAG_W3M=1
        ;;
      --git )
        FLAG_GIT=1
        ;;
      --clean )
        rm -rf ~/.*.backup*
        echo "clean done."
        exit 0
        ;;
      -h | --help )
        usage
        exit 0
        ;;
    esac
    shift
  done
}

parse_args $@

# 以下、インストール処理

INSTALL_RES="install result:"

if [ $FLAG_GIT -eq 1 ]; then
  cd ./git_setting/
  ./install.sh
  if [ $? -eq 0 ]; then
    INSTALL_RES="$INSTALL_RES\n    git install success"
  else
    INSTALL_RES="$INSTALL_RES\n    git install faild"
  fi
  cd ../
fi

if [ $FLAG_SHELL -eq 1 ]; then
  cd ./shell_setting/
  ./install.sh $SHELL_TYPE
  if [ $? -eq 0 ]; then
    INSTALL_RES="$INSTALL_RES\n    shell install success"
  else
    INSTALL_RES="$INSTALL_RES\n    shell install faild"
  fi
  cd ../
fi

if [ $FLAG_TMUX -eq 1 ]; then
  cd ./tmux_setting/
  ./install.sh
  if [ $? -eq 0 ]; then
    INSTALL_RES="$INSTALL_RES\n    tmux install success"
    INSTALL_RES="$INSTALL_RES\n        Prefix+I: plugins install"
    INSTALL_RES="$INSTALL_RES\n        Prefix+U: plugins upgrade"
    INSTALL_RES="$INSTALL_RES\n        Prefix+alt+u: plugins uninstall"
  else
    INSTALL_RES="$INSTALL_RES\n    tmux install faild"
  fi
  cd ../
fi

if [ $FLAG_VIM -eq 1 ]; then
  cd ./vim_setting/
  ./install.sh $VIM_TYPE
  if [ $? -eq 0 ]; then
    INSTALL_RES="$INSTALL_RES\n    vim install success"
  else
    INSTALL_RES="$INSTALL_RES\n    vim install faild"
  fi
  cd ../
fi

if [ $FLAG_W3M -eq 1 ]; then
  cd ./w3m_setting/
  ./install.sh
  if [ $? -eq 0 ]; then
    INSTALL_RES="$INSTALL_RES\n    w3m install success"
  else
    INSTALL_RES="$INSTALL_RES\n    w3m install faild"
  fi
  cd ../
fi

echo -e "$INSTALL_RES"
