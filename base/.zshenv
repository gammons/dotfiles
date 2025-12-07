export EDITOR=nvim
export WLR_DRM_NO_MODIFIERS=1
export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=sway

export PATH=$HOME/bin:$HOME/.bin:$PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=~/.local/bin:$PATH
export PATH=~/.local/share/omarchy/bin:$PATH
export PATH=$PATH:$(go env GOPATH)/bin
export PATH=$PATH:$HOME/.asdf/shims

export RUBYOPT="-r$HOME/.rubyopenssl_default_store.rb $RUBYOPT"

if [ x"${DESKTOP_SESSION}" != "gnome" ]; then
  eval $(keychain --eval --quiet id_rsa)
fi

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
