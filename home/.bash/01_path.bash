# Homebrew
if [ -d /usr/local/bin ]; then
  export PATH=/usr/local/bin:$PATH
  export PATH=$PATH:/usr/local/sbin
fi

if command -v foo >/dev/null 2>&1; then
  export PATH="$PATH:$(npm config get prefix)/bin"
fi

# Personal bin files
if [[ -d $HOME/.bin ]]; then
  export PATH=$HOME/.bin:$PATH
fi

export GOPATH=$HOME
if [[ -d $GOPATH ]]; then
  export PATH="$GOPATH/bin:$PATH"
fi

# # Use gnu utils instead of os x
# if [[ -d /usr/local/opt/coreutils/libexec/gnubin ]]; then
#   MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
#   MANPATH="/usr/local/opt/findutils/libexec/gnuman:$MANPATH"
#   PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH" 
#   PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
# fi

# export PYTHONPATH=/usr/local/lib/python2.7/site-packages
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"

export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
