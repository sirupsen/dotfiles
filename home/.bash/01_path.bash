# Homebrew
export PATH="/usr/local/opt/openjdk/bin:$PATH"
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
  export PATH="$PATH:$GOPATH/bin"
fi

export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.yarn/bin"
export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
export PATH="${PATH}:${HOME}/.krew/bin"
export PATH="${PATH}:${HOME}/src/zk"
export PATH="${PATH}:${HOME}/src/kotlin-language-server/server/build/install/server/bin"
export PATH="${PATH}:/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin"
