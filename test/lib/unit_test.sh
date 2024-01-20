#!/usr/bin/env bash


# テスト実行回数
TEST_CNT=0

# 正常回数
OK_CNT=0

# 異常回数
NG_CNT=0

# OK時の結果表示(0:非表示, 1:表示)
IS_DISPLAY_OK_RESULT=0


# 結果の表示
# $1-結果, $2-想定された値, $3-実際の結果の値 $4-テストの識別子
function put_result()
{
  local RES=$1
  local EXPECT=$2
  local RESULT=$3
  shift
  shift
  shift
  local TEST_EXTENSITON=$@
  TEST_CNT=`expr $TEST_CNT + 1`
  if [ ${RES} -eq 0 ]; then
    # 一致(緑)
    OK_CNT=`expr $OK_CNT + 1`
    if [ ${IS_DISPLAY_OK_RESULT} -eq 1 ]; then
      echo -e "\e[32mOK: ${TEST_EXTENSITON}: expect=${EXPECT}, result=${RESULT}\e[m"
    fi
  else
    # 不一致(赤)
    NG_CNT=`expr $NG_CNT + 1`
    echo -e "\e[31mNG: ${TEST_EXTENSITON}: expect=${EXPECT}, result=${RESULT}\e[m"
  fi
}

# 数値比較
# $1-想定する数値, $2-確認する数値, $3-テストの識別子
function unit_test_assert_equal_number()
{
  local RES
  local EXPECT=$1
  local RESULT=$2
  shift
  shift
  local TEST_EXTENSITON=$@

  if [ ${EXPECT} -eq ${RESULT} ]; then
    RES=0
  else
    RES=1
  fi

  put_result ${RES} ${EXPECT} ${RESULT} ${TEST_EXTENSITON}
}

# 文字列比較
# $1-想定する文字列, $2-確認する文字列, $3-テストの識別子
function unit_test_assert_equal_string()
{
  local RES
  local EXPECT=$1
  local RESULT=$2
  shift
  shift
  local TEST_EXTENSITON=$@

  if [ "${EXPECT}" == "${RESULT}" ]; then
    RES=0
  else
    RES=1
  fi

  put_result ${RES} ${EXPECT} ${RESULT} ${TEST_EXTENSITON}
}

# テストの初期化
# $1-OK時の結果表示設定(0:非表示, 1:表示)
function unit_test_init()
{
  TEST_CNT=0
  OK_CNT=0
  NG_CNT=0
  if [ $# -eq 0 ]; then
    IS_DISPLAY_OK_RESULT=0
  else
    IS_DISPLAY_OK_RESULT=$1
  fi
}

# テスト結果の表示
function unit_test_result()
{
  echo "total: ${TEST_CNT}, OK: ${OK_CNT}, NG: ${NG_CNT}"
}
