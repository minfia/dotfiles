#!/bin/bash

if [ -e ".vimrc" ]; then
  cp ~/.vimrc ~/.vimrc.bak
fi

cp .vimrc ~/
cp -r .vim/ ~/

