#!/usr/bin/env bash

. ./lib/unit_test.sh
. ../lib/package_manager.sh


# ディストリビューションの取得関数テスト
function test_get_distribution()
{
  local RESULT=`get_distribution`
  local EXPECT="Debian"

  unit_test_assert_equal_string ${EXPECT} ${RESULT} "distribution test(${LINENO})"
}

# パッケージ管理システムの取得関数テスト
test_get_package_manager()
{
  local DIST_NAME_LIST=("Ubuntu" "ubuntu" "UBUNTU" "Debian" "debian" "LinuxMint" "Linuxmint" "linuxmint" "Fedora" "Arch" "Gentoo" "d")
  local EXPECT_LIST=("apt" "apt" "apt" "apt" "apt" "apt" "apt" "apt" "dnf" "pacman" "emerge" "Unkown")

  for ((i=0; i<${#DIST_NAME_LIST[@]}; i++)); do
    local RESULT=`get_package_manager ${DIST_NAME_LIST[$i]}`
    local EXPECT=${EXPECT_LIST[$i]}
    unit_test_assert_equal_string ${EXPECT} ${RESULT} "pkg manager test(${LINENO})"
  done
}

# パッケージ管理システムでのインストール済みパッケージ確認関数テスト
function test_is_installed_from_pkg()
{
  local DIST_NAME=`get_distribution`
  local PKG_MNG=`get_package_manager ${DIST_NAME}`

  is_installed_from_pkg ${PKG_MNG} "tar"
  local RESULT=$?
  local EXPECT=0
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "pkg installed(${LINENO})"

  is_installed_from_pkg ${PKG_MNG} "TEST1"
  RESULT=$?
  EXPECT=1
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "pkg not installed(${LINENO})"

  is_installed_from_pkg "dkjasdf" "tar"
  RESULT=$?
  EXPECT=2
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "pkg not support package manager(${LINENO})"

  is_installed_from_pkg ${PKG_MNG}
  RESULT=$?
  EXPECT=3
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "pkg argument error(${LINENO})"
}

# パッケージ管理システムからパッケージをインストール関数テスト
function test_install_from_pkg()
{
  local DIST_NAME=`get_distribution`
  local PKG_MNG=`get_package_manager ${DIST_NAME}`

  install_from_pkg "dkjasdf" "tar"
  RESULT=$?
  EXPECT=1
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "pkg not support package manager(${LINENO})"

  install_from_pkg ${PKG_MNG}
  RESULT=$?
  EXPECT=2
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "pkg argument error(${LINENO})"
}

function test_upgrade_from_pkg()
{
  local DIST_NAME=`get_distribution`
  local PKG_MNG=`get_package_manager ${DIST_NAME}`

  upgrade_from_pkg "dkjasdf"
  RESULT=$?
  EXPECT=2
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "pkg not support package manager(${LINENO})"

  upgrade_from_pkg
  RESULT=$?
  EXPECT=3
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "pkg argument error(${LINENO})"
}

# アプリのインストールのチェック関数テスト
function test_is_installed_app()
{
  is_installed_app "ls"
  local RESULT=$?
  local EXPECT=0
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "exist test(${LINENO})"

  is_installed_app "TEST_CMD"
  RESULT=$?
  EXPECT=1
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "not exist test(${LINENO})"

  is_installed_app
  RESULT=$?
  EXPECT=2
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "arg error test(${LINENO})"
}

# インストール済みのアプリ一覧を取得関数テスト
function test_get_installed_cmds()
{
  local CMD_LIST=("ls" "TEST1" "TEST2" "cd")
  local RES_LIST=(`get_installed_cmds ${CMD_LIST[@]}`)
  local EXPECT_LIST=("ls" "cd")

  local EXPECT=${#EXPECT_LIST[@]}
  local RESULT=${#RES_LIST[@]}
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "cmd list array size(${LINENO})"

  for ((i=0; i<${#EXPECT_LIST[@]}; i++)); do
    unit_test_assert_equal_string ${EXPECT_LIST[$i]} ${RES_LIST[$i]} "cmd [$i](${LINENO})"
  done
}

# 未インストールのアプリ一覧を取得関数テスト
function test_get_not_installed_cmds()
{
  local CMD_LIST=("ls" "TEST1" "TEST2" "cd")
  local RES_LIST=(`get_not_installed_cmds ${CMD_LIST[@]}`)
  local EXPECT_LIST=("TEST1" "TEST2")

  local EXPECT=${#EXPECT_LIST[@]}
  local RESULT=${#RES_LIST[@]}
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "cmd list array size(${LINENO})"

  for ((i=0; i<${#EXPECT_LIST[@]}; i++)); do
    unit_test_assert_equal_string ${EXPECT_LIST[$i]} ${RES_LIST[$i]} "cmd [$i](${LINENO})"
  done
}

# PPAの追加関数テスト
function test_add_ppa_repo()
{
  local DIST_NAME="Debian"
  local REPO_LIST=("git-core/ppa" "jonathonf/vim")

  add_ppa_repo ${DIST_NAME} ${REPO_LIST}
  local RESULT=$?
  local EXPECT=2
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "add ppa distribution error(${LINENO})"

  DIST_NAME="Ubuntu"
  add_ppa_repo ${DIST_NAME}
  local RESULT=$?
  local EXPECT=3
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "add ppa array error(${LINENO})"
}

function main()
{
  unit_test_init 0

  test_get_distribution
  test_get_package_manager

  test_is_installed_from_pkg
  test_install_from_pkg
  test_upgrade_from_pkg

  test_is_installed_app
  test_get_installed_cmds
  test_get_not_installed_cmds

  test_add_ppa_repo

  unit_test_result
}

main
