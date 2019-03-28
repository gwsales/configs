#!/usr/bin/env bash

pip3 install --upgrade virtualenvwrapper --user
pip2 install --upgrade virtualenvwrapper --user

source `which virtualenvwrapper.sh`

rm -rf ~/.virtualenvs/main  2>/dev/null
rm -rf ~/.virtualenvs/main2 2>/dev/null
rm -rf ~/.virtualenvs/nvim2 2>/dev/null
rm -rf ~/.virtualenvs/nvim3 2>/dev/null

mkvirtualenv main -p python3
mkvirtualenv nvim3 -p python3

mkvirtualenv main2 -p python2
mkvirtualenv nvim2 -p python2

~/.virtualenvs/main/bin/pip  install ipython requests
~/.virtualenvs/main2/bin/pip install ipython requests

~/.virtualenvs/nvim2/bin/pip install neovim yapf
~/.virtualenvs/nvim3/bin/pip install neovim yapf

