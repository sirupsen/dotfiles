#/bin/bash

CHRUBY_VERSION="0.3.7"
VIM_VERSION="7.4"
RUBIES=( "ruby-2.0.0-p247" )

source ~/.bashrc

cores() {
  4
}

./linker.sh

if [[ ! -d $HOME/.vim/bundle/neobundle.vim ]]; then
  echo "Installing Neobundle.."
  git clone git://github.com/Shougo/neobundle.vim $HOME/.vim/bundle/neobundle.vim
  vim +NeoBundleInstall +qall
fi

if ! type -t chruby > /dev/null 2>&1; then
  echo "Installing chruby.."

  (
    cd /tmp
    wget -O "chruby-$CHRUBY_VERSION.tar.gz" "https://github.com/postmodern/chruby/archive/v$CHRUBY_VERSION.tar.gz"
    tar -xzvf "chruby-$CHRUBY_VERSION.tar.gz"
    cd "chruby-$CHRUBY_VERSION/"
    sudo make install
  )
fi

if [[ ! -d $HOME/.rubies ]]; then
  mkdir $HOME/.rubies
fi

if [[ ! -d $HOME/.rubies/ruby-trunk ]]; then
  git clone https://github.com/ruby/ruby.git ~/.rubies/ruby-trunk
fi

for ruby in "${RUBIES[@]}"; do
  if [[ ! -d $HOME/.rubies/$RUBY ]]; then
    echo "Installing packages required for $RUBY.."

    if [[ $(uname) = 'Linux' ]]; then
      sudo apt-get -y update
      sudo apt-get -y install build-essential zlib1g-dev libssl-dev\
        libreadline6-dev libyaml-dev libxslt-dev libxml2-dev
    fi

    echo "Installing $RUBY.."

    (
     cd $HOME/.rubies/ruby-trunk
     git checkout v2_0_0_247
     autoconf
     ./configure --prefix "$HOME/.rubies/$RUBY" --disable-install-doc
     make -j"$(cores)"
     make install
     git checkout master
    )
  fi
done

if ! vim --version | grep -q "+ruby"; then
  echo "Installing Vim 7.4 with Ruby support.."
  (
    cd /tmp
    wget "ftp://ftp.vim.org/pub/vim/unix/vim-$VIM_VERSION.tar.bz2"
    tar xjf "vim-$VIM_VERSION.tar.bz2"
    cd vim74
    source $HOME/.bashrc
    ruby --version
    ./configure --enable-rubyinterp
    make -j"$(cores)"
    sudo make install
  )
  
  # Refresh links
  hash -r
fi

if [[ ! -f $HOME/.vim/bundle/Command-T/ruby/command-t/match.o ]]; then
  echo "Compiling commandt.."
  (
    cd $HOME/.vim/bundle/Command-T/ruby/command-t
    ruby extconf.rb
    make clean
    make
  )
fi
