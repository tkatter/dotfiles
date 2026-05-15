# shellcheck disable=SC2148
# shellcheck disable=SC2164

# ls
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias lt='ls -lt --color=auto'
alias la='ls -la --color=auto'
alias l='ls -1 --color=auto'

# grep/ripgrep
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias zgrep='zgrep --color=auto'
if command -v "rg" &>/dev/null; then
  alias grep='rg'
else
  alias grep='grep --color=auto'
fi

# bat/batcat
if command -v "batcat" &>/dev/null; then
  alias cat='bat'
elif command -v "bat" &>/dev/null; then
  alias cat='bat'
fi

# Neovim
if command -v "nvim" &>/dev/null; then
  alias nv='nvim'
fi

# Lazygit
if command -v "lazygit" &>/dev/null; then
  alias lg='lazygit'
fi

# tmux
if command -v "tmux" &>/dev/null; then
  alias ntm='tmux new-session -s '
  alias ktm='tmux kill-server'
  alias tm='tmux'
  alias tma='tmux attach -t '
fi

# git
if command -v "git" &>/dev/null; then
  alias g='git '
  alias gbr='git branch'
  alias gci='git commit'
  alias gco='git checkout'
  alias ga='git add'
  alias gsw='git switch'
  alias gst='git status'
fi

if ! (command -v "hexdump" && command -v "hd")> /dev/null; then
  alias hd='hexdump -C'
fi

# diff
function diff() {
  [ -z "$1" ] && return
  [ -z "$2" ] && return

  if command -v "bat" &>/dev/null; then
    $(which diff) -u "$1" "$2" | bat -l diff -p
  elif command -v "batcat" &>/dev/null; then
    $(which diff) -u "$1" "$2" | batcat -l diff -p
  else
    $(which diff) --color -u "$1" "$2"
  fi
}

# Make and cd into dir
function mcd() {
  [ -z "$1" ] && return
  mkdir "$1" && cd "$1"
}
alias gf='/usr/local/bin/gf &'
