#/bin/bash
set -ex

#./linker.sh

if [[ ! -d $HOME/.vim/bundle/neobundle.vim ]]; then
  echo "Installing neobundle..."
  git clone git://github.com/Shougo/neobundle.vim $HOME/.vim/bundle/neobundle.vim
  vim +NeoBundleInstall +qall
fi

if ! chruby -v > /dev/null 2>&1; then
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
  (
    cd /tmp
    source /usr/local/share/chruby/chruby.sh 
    ruby --version

    wget "ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2"
    tar xjf "vim-7.4.tar.bz2"
    cd vim*
    ./configure --enable-rubyinterp
    make --jobs 4
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
