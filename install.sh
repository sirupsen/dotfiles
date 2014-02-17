#/bin/bash

# Exit immediately if anything exits with non-zero
set -e

# Print commands as we go
set -x

CHRUBY_VERSION="0.3.8"
VIM_VERSION="7.4"

./linker.sh

cores() {
  if [[ `uname` == 'Darwin' ]]; then
    `sysctl -n hw.ncpu`
  else
    `nproc`
  fi
}

./linker.sh

if [[ ! -d $HOME/.vim/bundle/neobundle.vim ]]; then
  echo "Installing neobundle..."
  git clone git://github.com/Shougo/neobundle.vim $HOME/.vim/bundle/neobundle.vim
  vim +NeoBundleInstall +qall
fi

if ! type -t chruby > /dev/null 2>&1; then
  (
    cd /tmp
    wget -O "chruby-$CHRUBY_VERSION.tar.gz" "https://github.com/postmodern/chruby/archive/v$CHRUBY_VERSION.tar.gz"
    tar -xzvf "chruby-$CHRUBY_VERSION.tar.gz"
    cd "chruby-$CHRUBY_VERSION/"
    sudo make install
  )
fi

if ! type -t ruby-install > /dev/null 2>&1; then
  (
    cd /tmp
    wget -O ruby-install-0.3.4.tar.gz https://github.com/postmodern/ruby-install/archive/v0.3.4.tar.gz
    tar -xzvf ruby-install-0.3.4.tar.gz
    cd ruby-install-0.3.4/
    sudo make install
  )
fi

if ! vim --version | grep -q "+ruby"; then
  echo "Installing Vim 7.4 with Ruby support..."
  (
    cd /tmp
    source /usr/local/share/chruby/chruby.sh 
    ruby --version

    wget "ftp://ftp.vim.org/pub/vim/unix/vim-$VIM_VERSION.tar.bz2"
    tar xjf "vim-$VIM_VERSION.tar.bz2"
    cd vim74
    ./configure --enable-rubyinterp
    make -j"$(cores)"
    sudo make install
  )

  # Refresh links
  hash -r
fi

echo "Compiling commandt..."
(
  cd $HOME/.vim/bundle/Command-T/ruby/command-t
  source /usr/local/share/chruby/chruby.sh 
  ruby extconf.rb
  make clean
  make
)
