#!/usr/bin/env bash


PROGRAM=$(basename $0)


function usage()
{
  echo "Usage: $PROGRAM [Options]..."
  echo "  This script is dotfiles installer."
  echo "Options:"
  echo "  --vim [company]  install vim setting"
  echo "  --tmux           install tmux setting"
  echo "  --shell TYPE     install shell setting"
  echo "  --w3m            install w3m setting"
  echo "  --git            install git setting"
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
    --w3m )
      FLAG_W3M=1
      ;;
    --git )
      FLAG_GIT=1
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

  cd ./vim_setting/
  ./install.sh $VIM_TYPE
  if [ $? -eq 0 ]; then
    INSTALL_RES="$INSTALL_RES\n    vim install success"
  else
    INSTALL_RES="$INSTALL_RES\n    vim install faild"
  fi
  cd ../
fi

if [ $FLAG_TMUX -eq 1 ]; then
  cd ./tmux_setting/
  ./install.sh
  if [ $? -eq 0 ]; then
    INSTALL_RES="$INSTALL_RES\n    tmux install success"
  else
    INSTALL_RES="$INSTALL_RES\n    tmux install faild"
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

echo -e "$INSTALL_RES"
