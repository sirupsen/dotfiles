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

install_mri_ruby() {
  if [[ ! -d "$HOME/.rubies/$1" ]]; then
    echo "Installing packages required for $1..."

    export platform=`uname | tr '[:upper:]' '[:lower:]'`

    if [[ $platform = 'linux' ]]; then
      sudo apt-get -y update
      sudo apt-get -y install build-essential zlib1g-dev libssl-dev\
        libreadline6-dev libyaml-dev libxslt-dev libxml2-dev
    fi

    echo "Installing $1..."

    (
      cd /tmp

      mkdir -p ~/.rubies

      if wget "http://shopify-vagrant.s3.amazonaws.com/rubies/$1-$platform.tar.gz"; then
        tar zxf "$1-$platform.tar.gz"
        mv /tmp/$1 ~/.rubies/
      else
        wget http://cache.ruby-lang.org/pub/ruby/$1.tar.gz
        tar zxf $1.tar.gz
        cd $1

        ./configure --prefix "$HOME/.rubies/$1" --disable-install-doc
        make -j"$(cores)"
        make install
      fi

      rm -rf /tmp/ruby-*
    )
  fi
}

./linker.sh

if [[ ! -d $HOME/.vim/bundle/neobundle.vim ]]; then
  echo "Installing neobundle..."
  git clone git://github.com/Shougo/neobundle.vim $HOME/.vim/bundle/neobundle.vim
  vim +NeoBundleInstall +qall
fi

if ! type -t chruby > /dev/null 2>&1; then
  echo "Installing chruby..."

  (
    cd /tmp
    wget -O "chruby-$CHRUBY_VERSION.tar.gz" "https://github.com/postmodern/chruby/archive/v$CHRUBY_VERSION.tar.gz"
    tar -xzvf "chruby-$CHRUBY_VERSION.tar.gz"
    cd "chruby-$CHRUBY_VERSION/"
    sudo make install
  )
fi

install_mri_ruby "ruby-2.0.0-p353"
install_mri_ruby "ruby-1.9.3-p484"

if ! vim --version | grep -q "+ruby"; then
  echo "Installing Vim 7.4 with Ruby support..."
  (
    cd /tmp
    source /usr/local/share/chruby/chruby.sh 
    chruby 2.0.0

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

echo "Compiling commandt..."
(
  cd $HOME/.vim/bundle/Command-T/ruby/command-t
  source /usr/local/share/chruby/chruby.sh 
  chruby 2.0.0
  ruby extconf.rb
  make clean
  make
)
