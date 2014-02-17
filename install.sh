#/bin/bash
set -ex

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
    git clone git@github.com:postmodern/chruby.git /tmp/chruby-latest
    cd /tmp/chruby-latest
    sudo make install
    rm -rf /tmp/chruby-latest
  )
fi

if ! type -t ruby-install > /dev/null 2>&1; then
  (
    git clone git@github.com:postmodern/ruby-install.git /tmp/ruby-install-latest
    sudo make install
    rm -rf /tmp/ruby-install-latest
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
