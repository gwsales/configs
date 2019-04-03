#!/usr/bin/env bash
CUR_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"

mkdir -p ${HOME}/.config

function setup_link() {
    src="$1"
    dst="$2"

    if [[ "x$1" == "x" ]]; then
        echo no src for setupLink func
        exit 1
    fi

    if [[ "x$2" == "x" ]]; then
        echo no dst for setupLink func
        exit 1
    fi

    if [[ -d "$dst" ]]; then
        rm -rf "$dst"
    elif [[ -f "$dst" ]]; then
        rm -f "$dst"
    fi

    ln -s "$src" "$dst"
}

function setup_single() {
    if [[ "x$1" == "x" ]]; then
        echo no src for setupLink func
        exit 1
    fi

    src="${CUR_DIR}/$1"
    if [[ -f "$src" ]]; then
        setup_link "$src" "${HOME}/$1"
    else
        echo weird src?
        exit 1
    fi
}

## xcode tests
xcode-select -p >/dev/null
if [ $? -ne 0 ]; then
    echo "Need to install xcode command line tools"
    echo "Run 'xcode-select --install'"
    exit 1
else
    echo "xcode already installed"
fi

# Setup brew if not installed
which brew >/dev/null
if [ $? -ne 0 ]; then
    echo "Installing homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Homebrew already installed"
fi

echo "Update Brew"
brew upgrade

which openssl > /dev/null
if [ $? -ne 0 ]; then
   echo 'Install openssl'
   brew install openssl
else
    echo "openssl already installed"
fi

which curl > /dev/null
if [ $? -ne 0 ]; then
   echo 'Installing curl'
   brew install curl --with-libssh2 --with-nghttp2 --with-openssl
fi

# Install required brew packages for setup
which git >/dev/null
if [ $? -ne 0 ]; then
    brew install git --with-curl --with-openssl
fi

which zsh >/dev/null
if [ $? -ne 0 ]; then
    brew install zsh --with-pcre
fi

which python3 >/dev/null
if [ $? -ne 0 ]; then
    brew install python
fi

which python2 >/dev/null
if [ $? -ne 0 ]; then
    brew install python2
fi

which cmake >/dev/null
if [ $? -ne 0 ]; then
    brew install cmake
fi

# Setup pip
pip3 install --upgrade pip setuptools wheel
pip2 install --upgrade pip setuptools wheel


brew bundle install --file="$CUR_DIR/Brewfile_basic"

## Links
setup_link "${CUR_DIR}/_vimrc"        "${HOME}/.vimrc"
setup_link "${CUR_DIR}/vimfiles"      "${HOME}/.vim"
setup_link "${CUR_DIR}/Fonts"         "${HOME}/.fonts"

#setup_single .emacs
setup_single .bash_aliases
setup_single .gitattributes
#setup_single .ctags
setup_single .ideavimrc

if [ ! -f ${HOME}/.gitconfig ]; then
    cp ${CUR_DIR}/myGitConfig ${HOME}/.gitconfig
fi

rm -f ${HOME}/.zshrc
if [[ `uname` -eq "Darwin" ]]; then
    setup_link "${CUR_DIR}/.zshrc_mac" "${HOME}/.zshrc"
else
    setup_single "${CUR_DIR}/.Xresources"

    setup_link "${CUR_DIR}/.zshrc_arch" "${HOME}/.zshrc"
    setup_link "${CUR_DIR}/.configs/i3" "${HOME}/.config/i3"
fi

setup_link "${CUR_DIR}/vimfiles" "${HOME}/.config/nvim"

## Virts

pip3 install --upgrade virtualenvwrapper --user
pip2 install --upgrade virtualenvwrapper --user

#source `which virtualenvwrapper.sh`

#rm -rf ~/.virtualenvs/main  2>/dev/null
#rm -rf ~/.virtualenvs/main2 2>/dev/null
#rm -rf ~/.virtualenvs/nvim2 2>/dev/null
#rm -rf ~/.virtualenvs/nvim3 2>/dev/null

#mkvirtualenv main -p python3
#mkvirtualenv nvim3 -p python3

#mkvirtualenv main2 -p python2
#mkvirtualenv nvim2 -p python2

#~/.virtualenvs/main/bin/pip  install ipython requests
#~/.virtualenvs/main2/bin/pip install ipython requests

#~/.virtualenvs/nvim2/bin/pip install neovim yapf
#~/.virtualenvs/nvim3/bin/pip install neovim yapf


## git submodule
ycm="${CUR_DIR}/vimfiles/bundle/YouCompleteMe"
git submodule update --recursive --init
cd "$ycm"
python3 ./install.py


