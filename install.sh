#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

inst_method="symlink"
[[ "$1" == "install" ]] && inst_method="$1"
bin="rem"

install_if_on_path() {
  if grep -q "$1" <<< "$PATH"; then
    if [[ "$inst_method" == "symlink" ]]; then
      ln -s "$(realpath "$bin")" "$1/$bin"
    else
      install -m 755 -D "$bin" "$1/$bin"
    fi
  else
    echo "$1 not on \$PATH, continuing"
    return 1
  fi
}

install_if_on_path "$HOME/.local/bin" \
  || install_if_on_path "/usr/local/bin" \
  || install_if_on_path "/usr/bin" \
  || install_if_on_path "/sbin" \
  || {
    echo "Could not find suitable location, exiting"
    return 1
  }
