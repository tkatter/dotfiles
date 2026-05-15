#!/usr/bin/env bash
##
# Interactive search. Use fzf as an interface for ripgrep.
# Usage: `ff` or `ff <folder>`.

ff() {
  [[ -n $1 ]] && cd $1 # go to provided folder or noop
  RG_DEFAULT_COMMAND="rg -i -l --hidden \
    -g !.local/{state,share} \
    -g !.Private \
    -g !.asdf \
    -g !.cache \
    -g !target \
    -g !node_modules \
    -g !.cargo \
    -g !.steam \
    -g !.var \
    -g !.rustup \
    -g !.hex \
    -g !.icons \
    -g !_build \
    -g !.mozilla \
    -g !.elixir_ls \
    -g !deps \
    -g !.git \
    -g !.npm \
    -g !assets \
    -g !.pgadmin \
    -g !.ecryptfs \
    -g !.gnupg \
    -g !.linuxmint"

  selected=$(
    FZF_DEFAULT_COMMAND="rg --files" fzf \
      -m \
      -e \
      --ansi \
      --disabled \
      --bind "ctrl-a:select-all" \
      --bind "change:reload:$RG_DEFAULT_COMMAND {q} || true" \
      --preview "rg -i --pretty --context 3 {q} {}"
  )

  [[ -n $selected ]] && $EDITOR $selected # open multiple files in editor
}
