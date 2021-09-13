#!/bin/bash


if [ $# -ne 1 ]; then
  echo "argument error."
  exit 1
fi


if [ "$1" == "bash" ]; then
  cd bash/
  ./install.sh
  cd ../
  exit $?
fi


echo "$1 unsupported shell type"

exit 1
