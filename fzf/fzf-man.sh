#!/usr/bin/env bash
# Fuzzy find manpages and preview them with bat

fman() {
  man -k . | fzf -q "$1" \
    --prompt='man> ' \
    --preview $' echo {} \\
      | tr -d \'\(\)\' \\
      | awk \'{print $1}\' \\
      | tr -d \'[:digit:]\' \\
      | xargs -r man \\
      | col -bx \\
      | bat -l man -p --color always' |
    xargs -r man
}

# Get the colors in the opened man page itself
export MANPAGER="sh -c 'col -bx | bat -l man -p --paging always'"
