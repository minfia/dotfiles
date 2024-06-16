#!/usr/bin/env bash


# ディストリビューションを取得
# ret: ディストリビューション名
function get_distribution()
{
  local DISTRIBUTION

  #if command -v lsb_release 2>/dev/null; then
  #  DISTRIBUTION=$(lsb_release -a 2>&1 | grep 'Distributor ID' | awk '{print $3}')
  if [ -e /etc/debian_version ]; then
    if [ -e /etc/lsb-release ]; then
      DISTRIBUTION=$(cat /etc/lsb-release | grep 'DISTRIB_ID' | awk -F'[=]' '{print $2}')
    else
      DISTRIBUTION="Debian"
    fi
  elif [ -e /etc/fedora-release ]; then
    DISTRIBUTION="Fedora"
  elif [ -e /etc/redhat-release ]; then
    DISTRIBUTION=$(cat /etc/redhat-release | cut -d ' ' -f 1)
  elif [ -e /etc/arch-release ]; then
    DISTRIBUTION="Arch"
  elif [ -e /etc/SuSE-release ]; then
    DISTRIBUTION="SUSE"
  elif [ -e /etc/gentoo-release ]; then
    DISTRIBUTION="Gentoo"
  elif [ "$(uname)" == "Darwin" ]; then
    DISTRIBUTION="macOS"
  else
    DISTRIBUTION="Unkown"
  fi

  echo ${DISTRIBUTION}
}

# パッケージ管理システム名の取得
# $1-ディストリビューション名
# ret: パッケージ管理システム名
function get_package_manager()
{
  local PKG_MNG_SYS

  case "$1" in
    "Ubuntu" | "ubuntu" | "UBUNTU" | "Debian" | "debian" | "LinuxMint" | "Linuxmint" | "linuxmint" )
      PKG_MNG_SYS="apt"
      ;;
    "Fedora" )
      PKG_MNG_SYS="dnf"
      ;;
    "Arch" )
      PKG_MNG_SYS="pacman"
      ;;
    "Gentoo" )
      PKG_MNG_SYS="emerge"
      ;;
    * )
      PKG_MNG_SYS="Unkown"
      ;;
  esac

  echo ${PKG_MNG_SYS}
}

# パッケージ管理システムでのインストール済みパッケージ確認
# $1-対象とするパッケージ管理システム, $2-チェックするパッケージ
# 0: インストール済み, 1: 未インストール, 2: 非対応パッケージ管理システム, 3: 引数エラー
function is_installed_from_pkg_mng()
{
  if [ -z "$1" ] || [ -z "$2" ]; then
    return 3
  fi
  local LIST
  local PKG

  case "$1" in
    "apt" )
      LIST=(`dpkg -l | grep -E "^ii  $2"`)
      local PKG_ARR=(${LIST[1]//:/ })
      PKG=${PKG_ARR[0]}
      ;;
    "pip3" )
      LIST=(`pip3 list --format=columns | grep $2`)
      PKG=${LIST[0]}
      ;;
    * )
      return 2
      ;;
  esac

  if [ "$PKG" = "$2" ]; then
    return 0
  else
    return 1
  fi
}

# 実パッケージ名の確認
# $1-対象とするパッケージ管理システム, $2-チェックするパッケージ
# 空文字列: 非仮想パッケージ, 空文字列以外: 実パッケージ名, 1の文字列: 非対応パッケージ管理システム, 2の文字列: 引数エラー
function get_virtual_pkg_name_from_pkg_mng()
{
  local PKG_RES=""
  if [ $# -ne 2 ]; then
    echo "2"
    return
  fi

  local PKG_MNG=$1
  local PKG=$2

  case "${PKG_MNG}" in
    "apt" )
      local LIST=(`apt-cache showpkg ${PKG}`)
      for ((i=0; i<${#LIST[@]}; i++)); do
        # "Reverse Provides:の検索"
        if [ "${LIST[${i}]}" == "Reverse" ] && [ "${LIST[${i}+1]}" == "Provides:" ]; then
          PKG_RES=${LIST[${i}+2]}
          break
        fi
      done
      ;;
    * )
      echo "1"
      return
      ;;
  esac

  echo "${PKG_RES}"
}

# パッケージ管理システムからパッケージをインストール
# $1-対象とするパッケージ管理システム, $2-インストールするパッケージの配列
# 0: 正常終了, 1: 非対応パッケージ管理システム, 2: 引数エラー
function install_from_pkg_mng()
{
  if [ 1 -ge $# ]; then
    return 2
  fi

  local PKG_MNG=$1
  shift

  case "${PKG_MNG}" in
    "apt" )
      sudo apt-get install -y "$@"
      ;;
    "pip3" )
      pip3 install "$@"
      ;;
    * )
      return 1
      ;;
  esac

  return 0
}

# パッケージ管理システムからパッケージのアップグレード
# $1-対象とするパッケージ管理システム
# 0: 正常終了, 1: 異常終了, 2: 非対応パッケージ管理システム, 3: 引数エラー
function upgrade_from_pkg_mng()
{
  if [ -z "$1" ]; then
    return 3
  fi

  local RET
  case "$1" in
    "apt" )
      sudo apt upgrade -y
      RET=$?
      ;;
    * )
      return 2
      ;;
  esac

  if [ ${RET} -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

# インストールのアプリ一覧を取得
# パッケージ管理システムは省略可能でその場合はディストリビューションのパッケージ管理システムを使用する
# $1-対象とするパッケージ管理システム, $2-アプリ名の配列
# ret: 未インストールアプリ一覧
function get_installed_pkgs_from_pkg_mng()
{
  if [ $# -eq 0 ]; then
    return 2
  fi

  local PKG_MNG=$1
  shift
  if [ "${PKG_MNG}" == "" ]; then
    local DIST_NAME=`get_distribution`
    PKG_MNG=`get_package_manager "${DIST_NAME}"`
  fi

  local PKG_ARR=($@)
  local PKG_SIZE=${#PKG_ARR[@]}
  local ARR
  local CNT=0

  for ((i=0; i<${PKG_SIZE}; i++)); do
    local PKG=${PKG_ARR[$i]}
    is_installed_from_pkg_mng "${PKG_MNG}" "${PKG}"
    if [ $? -eq 0 ]; then
      # インストール済み
      ARR[${CNT}]=${PKG}
      CNT=`expr ${CNT} + 1`
    else
      # 仮想パッケージの可能性あり
      local V_PKG=`get_virtual_pkg_name_from_pkg_mng "${PKG_MNG}" "${PKG}"`
      if [ "${V_PKG}" == "" ]; then
        # 実パッケージかつ未インストール
        continue
      else
        # 仮想パッケージでインストール済みか確認
        is_installed_from_pkg_mng "${PKG_MNG}" "${V_PKG}"
        if [ $? -eq 0 ]; then
          # インストール済み
          ARR[${CNT}]=${PKG}
          CNT=`expr ${CNT} + 1`
        fi
      fi
    fi
  done

  echo ${ARR[@]}
}

# 未インストールのアプリ一覧を取得
# パッケージ管理システムは省略可能でその場合はディストリビューションのパッケージ管理システムを使用する
# $1-対象とするパッケージ管理システム, $2-アプリ名の配列
# ret: 未インストールアプリ一覧
function get_not_installed_pkgs_from_pkg_mng()
{
  if [ $# -eq 0 ]; then
    return 2
  fi

  local PKG_MNG=$1
  shift
  if [ "${PKG_MNG}" == "" ]; then
    local DIST_NAME=`get_distribution`
    PKG_MNG=`get_package_manager "${DIST_NAME}"`
  fi

  local PKG_ARR=($@)
  local PKG_SIZE=${#PKG_ARR[@]}
  local ARR
  local CNT=0

  for ((i=0; i<${PKG_SIZE}; i++)); do
    local PKG=${PKG_ARR[$i]}
    is_installed_from_pkg_mng "${PKG_MNG}" "${PKG}"
    if [ $? -eq 0 ]; then
      # インストール済み
      continue
    else
      # 仮想パッケージの可能性あり
      local V_PKG=`get_virtual_pkg_name_from_pkg_mng "${PKG_MNG}" "${PKG}"`
      if [ "${V_PKG}" == "" ]; then
        # 実パッケージかつ未インストール
        ARR[${CNT}]=${PKG}
        CNT=`expr ${CNT} + 1`
      else
        # 仮想パッケージでインストール済みか確認
        is_installed_from_pkg_mng "${PKG_MNG}" "${V_PKG}"
        if [ $? -ne 0 ]; then
          # 未インストール
          ARR[${CNT}]=${PKG}
          CNT=`expr ${CNT} + 1`
        fi
      fi
    fi
  done

  echo ${ARR[@]}
}

# PPAの追加
# $1-対象とするパッケージ管理システム, $2-追加するリポジトリ(例: ppa:git-core/ppaなら、git-core/ppaの部分)のリスト
# 0: 成功, 1: 失敗 2: ディストリビューションエラー 3: 配列要素なし
function add_ppa_repo()
{
  local DISTRIBUTION=$1
  if [ "${DISTRIBUTION}" != "Ubuntu" ] && [ "${DISTRIBUTION}" != "ubuntu" ] && [ "${DISTRIBUTION}" != "UBUNTU" ] && \
     [ "${DISTRIBUTION}" != "LinuxMint" ] && [ "${DISTRIBUTION}" != "Linuxmint" ] && [ "${DISTRIBUTION}" != "linuxmint" ]; then
    return 2
  fi

  shift
  local PPA_LIST=($@)
  local PPA_LIST_SIZE=${#PPA_LIST[@]}

  if [ ${PPA_LIST_SIZE} -eq 0 ]; then
    return 3
  fi

  local PPA_LIST_DIR=/var/lib/apt/lists/
  local PPA_LAUNCHPAD_BASE_NAME=ppa.launchpad.net_
  local ADD_FLG=0

  for ((i=0; i<$PPA_LIST_SIZE; i++)); do
    local PPA_ITEM=`echo ${PPA_LIST[i]//\//_}`
    ls ${PPA_LIST_DIR}${PPA_LAUNCHPAD_BASE_NAME}${PPA_ITEM}* > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      sudo add-apt-repository -y ppa:${PPA_LIST[i]}
      ADD_FLG=1
    else
      return 1
    fi
  done

  if [ ${ADD_FLG} -ne 0 ]; then
    sudo apt update
    upgrade_from_pkg_mng "apt"
  fi

  return 0
}

# アプリのインストールのチェック
# $1-アプリ名
# 0: インストール済み, 1: 未インストール, 2: 引数エラー
function is_installed_app()
{
  if [ $# -ne 1 ]; then
    return 2
  fi

  local EXEC_CMD=$1

  type ${EXEC_CMD} > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    return 0
  else
    return 1
  fi
}
