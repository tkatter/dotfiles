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
if [[ $(uname -s) == "FreeBSD" ]]; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p --paging always'"
else
  if command -v "batcat" &>/dev/null; then
    export MANPAGER="sh -c 'batcat -l man --style plain --paging always'"
  elif command -v "bat" &>/dev/null; then
    export MANPAGER="sh -c 'bat -l man --style plain --paging always'"
  fi
fi
