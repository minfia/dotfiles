#!/usr/bin/env bash

. ./lib/unit_test.sh
. ../lib/generic.sh

# 文字列挿入関数テスト
function test_insert_string_in_file()
{
  local FILE_BASE_PATH="./"
  local FILE_NAME="TEST.txt"
  rm -f ${FILE_BASE_PATH}${FILE_NAME}

  insert_string_in_file ${FILE_BASE_PATH}${FILE_NAME}
  local RESULT=$?
  local EXPECT=2
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "insert string argument error(${LINENO})"

  insert_string_in_file ${FILE_BASE_PATH}${FILE_NAME} "ddddd"
  local RESULT=$?
  local EXPECT=3
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "insert string not exist file(${LINENO})"

  echo "" > ${FILE_BASE_PATH}${FILE_NAME}
  insert_string_in_file ${FILE_BASE_PATH}${FILE_NAME} ""
  local RESULT=$?
  local EXPECT=4
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "insert string string blank(${LINENO})"

  insert_string_in_file ${FILE_BASE_PATH}${FILE_NAME} "ddddd"
  local RESULT=$?
  local EXPECT=0
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "insert string success insert(${LINENO})"

  insert_string_in_file ${FILE_BASE_PATH}${FILE_NAME} "ddddd"
  local RESULT=$?
  local EXPECT=1
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "insert string already insert string(${LINENO})"

  insert_string_in_file ${FILE_BASE_PATH}${FILE_NAME} "space string"
  local RESULT=$?
  local EXPECT=0
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "insert string already insert string in space(${LINENO})"

  rm -f ${FILE_BASE_PATH}${FILE_NAME}
}

# 指定した権限をユーザーが持っているか確認関数テスト
function test_is_auth_in_str()
{
  is_auth_in_str "sudo"
  local RESULT=$?
  local EXPECT=0
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "sudo authority(${LINENO})"

  is_auth_in_str "TTTTT"
  local RESULT=$?
  local EXPECT=1
  unit_test_assert_equal_number ${EXPECT} ${RESULT} "TTTTT authority(${LINENO})"
}

# 配列の中身を逆順にする関数テスト
function test_reverse_array()
{
  local ARRAY=("")
  local RESULT
  local EXPECT

  local RES_LIST=`reverse_array ${ARRAY}`
  local EXPECT_LIST=("")
  unit_test_assert_equal_string "${EXPECT_LIST}" "${RES_LIST}" "reverse array non data(${LINENO})"

  ARRAY=(1 2 3 4 5)
  RES_LIST=(`reverse_array ${ARRAY[@]}`)
  EXPECT_LIST=(5 4 3 2 1)

  for ((i=0; i<${#EXPECT_LIST[@]}; i++)); do
    RESULT=${RES_LIST[${i}]}
    EXPECT=${EXPECT_LIST[${i}]}
    unit_test_assert_equal_number ${EXPECT} ${RESULT} "reverse array number data(${LINENO})"
  done

  ARRAY=("test1" "test2" "test3" "test4")
  RES_LIST=(`reverse_array "${ARRAY[@]}"`)
  EXPECT_LIST=("test4" "test3" "test2" "test1")
  for ((i=0; i<${#EXPECT_LIST[@]}; i++)); do
    RESULT="${RES_LIST[${i}]}"
    EXPECT="${EXPECT_LIST[${i}]}"
    unit_test_assert_equal_string "${EXPECT}" "${RESULT}" "reverse array string data(${LINENO})"
  done
}

function main()
{
  unit_test_init 0

  test_insert_string_in_file
  test_is_auth_in_str
  test_reverse_array

  unit_test_result
}

main
