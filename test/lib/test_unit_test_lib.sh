#!/usr/bin/env bash


. ./unit_test.sh

function test_display_ok()
{
  echo "initial unit_test"
  unit_test_init 1
  unit_test_result

  unit_test_assert_equal_number 1 1 "equal(number)"
  unit_test_assert_equal_number 1 0 "not equal(number)"

  unit_test_assert_equal_string "test" "test" "equal(string)"
  unit_test_assert_equal_string "test" "tes" "not equal(string)"

  echo "run unit_test"
  unit_test_result

  echo "reset unit_test"
  unit_test_init 1
  unit_test_result
}

function test_not_display_ok()
{
  echo "initial unit_test"
  unit_test_init 0
  unit_test_result

  unit_test_assert_equal_number 1 1 "equal(number)"
  unit_test_assert_equal_number 1 0 "not equal(number)"

  unit_test_assert_equal_string "test" "test" "equal(string)"
  unit_test_assert_equal_string "test" "tes" "not equal(string)"

  echo "run unit_test"
  unit_test_result

  echo "reset unit_test"
  unit_test_init 0
  unit_test_result
}

function main()
{
  echo "****** display ok ******"
  test_display_ok
  echo "****** not display ok ******"
  test_not_display_ok
}

main
