#!/bin/bash


PROGRAM=$(basename $0)


function usage()
{
  echo "Usage $PROGRAM [Options]..."
  echo -e "\tThis script is dotfiles install."
  echo "Options:"
  echo -e "\tvim [company]  install normal vim setting"
  echo -e "\ttmux          install tmux setting"
  echo -e "\tshell TYPE    install shell setting"
  echo -e "\t-h, --help    show help"
}


if [ $# -eq 0 ]; then
  usage
  exit 0
fi


FLAG_VIM=0
FLAG_TMUX=0
FLAG_SHELL=0


VIM_TYPE=
SHELL_TYPE=


for OPT in "$@"
do
  case $OPT in
    --vim )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        FLAG_VIM=1
      elif [[ "$2" == "company" ]]; then
        FLAG_VIM=1
        VIM_TYPE="company"
        shift
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
    -h | --help )
      usage
      exit 0
      ;;
  esac
  shift
done


# 以下、インストール処理

INSTALL_RES="install result:"

if [ $FLAG_VIM -eq 1 ]; then
  ./vim_setting/install.sh $VIM_TYPE
  if [ $? -eq 0 ]; then
    INSTALL_RES="$INSTALL_RES\n    vim install success"
  else
    INSTALL_RES="$INSTALL_RES\n    vim install faild"
  fi
fi

if [ $FLAG_TMUX -eq 1 ]; then
  ./tmux_setting/install.sh
  if [ $? -eq 0 ]; then
    INSTALL_RES="$INSTALL_RES\n    tmux install success"
  else
    INSTALL_RES="$INSTALL_RES\n    tmux install faild"
  fi
fi

if [ $FLAG_SHELL -eq 1 ]; then
  case $SHELL_TYPE in
    "bash" )
      ./shell_setting/install.sh
      if [ $? -eq 0 ]; then
        INSTALL_RES="$INSTALL_RES\n    shell install success"
      else
        INSTALL_RES="$INSTALL_RES\n    shell install faild"
      fi
      ;;
    * )
      INSTALL_RES="$INSTALL_RES\n    $SHELL_TYPE unsupported shell type"
      ;;
  esac
fi

echo -e "$INSTALL_RES"
