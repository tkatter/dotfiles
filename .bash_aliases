# ls
alias ll='ls -l'
alias la='ls -al'
alias l='ls -1'

# batcat
if command -v "batcat" &>/dev/null; then
  alias cat='bat'
elif command -v "bat" &>/dev/null; then
  alias cat='bat'
fi

# Directory
alias mcd='mkdir'

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
  alias gbr='git br'
  alias gci='git ci'
  alias gco='git co'
  alias ga='git add'
  alias gsw='git sw'
  alias gst='git st'
fi
