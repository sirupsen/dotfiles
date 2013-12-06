#/bin/bash

# Exit immediately if anything exits with non-zero
set -e

# Print commands as we go
set -x

CHRUBY_VERSION="0.3.7"
VIM_VERSION="7.4"

cores() {
  4
}

# $1: Ruby version (ruby-2.0.0-p247
# $2: Ruby git sha for version (v2_0_0_247)
install_mri_ruby() {
  if [[ ! -d "$HOME/.rubies/$1" ]]; then
    echo "Installing packages required for $1"

    if [[ $(uname) = 'Linux' ]]; then
      sudo apt-get -y update
      sudo apt-get -y install build-essential zlib1g-dev libssl-dev\
        libreadline6-dev libyaml-dev libxslt-dev libxml2-dev
    fi

    echo "Installing $1"

    (
     cd $HOME/.rubies/ruby-trunk
     git checkout $2
     git clean -f
     autoconf
     ./configure --prefix "$HOME/.rubies/$1" --disable-install-doc
     make -j"$(cores)"
     make install
     git checkout trunk

     source ~/.bashrc
     chruby $1
     gem install bundler
    )
  fi
}

./linker.sh

if [[ ! -d $HOME/.vim/bundle/neobundle.vim ]]; then
  echo "Installing Neobundle"
  git clone git://github.com/Shougo/neobundle.vim $HOME/.vim/bundle/neobundle.vim
  vim +NeoBundleInstall +qall
fi

if ! type -t chruby > /dev/null 2>&1; then
  echo "Installing chruby"

  (
    cd /tmp
    wget -O "chruby-$CHRUBY_VERSION.tar.gz" "https://github.com/postmodern/chruby/archive/v$CHRUBY_VERSION.tar.gz"
    tar -xzvf "chruby-$CHRUBY_VERSION.tar.gz"
    cd "chruby-$CHRUBY_VERSION/"
    sudo make install
  )
fi

if [[ ! -d $HOME/.rubies/ruby-trunk ]]; then
  git clone https://github.com/ruby/ruby.git ~/.rubies/ruby-trunk
fi

install_mri_ruby "ruby-2.0.0-p353" "v2_0_0_353"

if ! vim --version | grep -q "+ruby"; then
  echo "Installing Vim 7.4 with Ruby support"
  (
    cd /tmp
    wget "ftp://ftp.vim.org/pub/vim/unix/vim-$VIM_VERSION.tar.bz2"
    tar xjf "vim-$VIM_VERSION.tar.bz2"
    cd vim74
    ruby --version
    ./configure --enable-rubyinterp
    make -j"$(cores)"
    sudo make install
  )
  
  # Refresh links
  hash -r
fi

if [[ ! -f $HOME/.vim/bundle/Command-T/ruby/command-t/match.o ]]; then
  echo "Compiling commandt"
  (
    cd $HOME/.vim/bundle/Command-T/ruby/command-t
    ruby extconf.rb
    make clean
    make
  )
fi
