# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

## XDG Base Directories
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_STATE_HOME="$HOME/.local/state"

## Export EDITOR env variable
if command -v "nvim" &>/dev/null; then
  export EDITOR="$(command -v nvim)"
elif command -v "vim" &>/dev/null; then
  export EDITOR="$(command -v vim)"
elif command -v "vi" &>/dev/null; then
  export EDITOR="$(command -v vi)"
else
  export EDITOR="nano" # last resort
fi

## Export `$HOME/.local/bin`
LOCAL_BIN="$HOME/.local/bin"
if [ -d "$LOCAL_BIN" ]; then
  case ":$PATH:" in
  *":$LOCAL_BIN:"*) : ;; # already in PATH, do nothing
  *) export PATH="$LOCAL_BIN:$PATH" ;;
  esac
fi

## Bash completion (FreeBSD)
[[ $PS1 && -f /usr/local/share/bash-completion/bash_completion.sh ]] && \
  source /usr/local/share/bash-completion/bash_completion.sh

## History sync between shells
PROMPT_COMMAND='history -a; history -n'

## If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

## Don't put duplicate lines or lines starting with space in the history.
## See bash(1) for more options
HISTCONTROL=ignoreboth

## Append to the history file, don't overwrite it
shopt -s histappend

## For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

## Check the window size after each command and, if necessary,
## update the values of LINES and COLUMNS.
shopt -s checkwinsize

## If set, the pattern "**" used in a pathname expansion context will
## match all files and zero or more directories and subdirectories.
shopt -s globstar


## Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

## Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

## Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

## We want color baby
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    ## We have color support; assume it's compliant with Ecma-48
    ## (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    ## a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  if [ ! -z "$debian_chroot" ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;38;5;219m\]\u@\[\033[00;38;5;147m\]\h\[\033[00m\] \[\033[02;38;5;105m\]\w\[\033[00m\] \[\033[01;38;5;219m\]\$\[\033[00m\] '
  else
    PS1='\[\033[00;38;5;147m\](\h)\[\033[00m\]\[\033[01;38;5;219m\]\u\[\033[00m\] \[\033[02;38;5;105m\]\w\[\033[00m\] \[\033[01;38;5;219m\]\$\[\033[00m\] '
  fi
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

case "$TERM" in
xterm* | rxvt*)
  PS1='\[\033[00;38;5;147m\](\h)\[\033[00m\]\[\033[01;38;5;219m\]\u\[\033[00m\] \[\033[02;38;5;105m\]\w\[\033[00m\] \[\033[01;38;5;219m\]\$\[\033[00m\] '
  ;;
*) ;;
esac

## enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  # alias grep='grep --color=auto'
  if command -v "rg" &>/dev/null; then
    alias grep='rg'
  fi
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
else
  alias ls='ls -G'
  if command -v "rg" &>/dev/null; then
    alias grep='rg'
  fi
fi

## colored GCC warnings and errors
# export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

## Add an "alert" alias for long running commands.  Use like so:
##   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

## Source .bash_aliases
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

## enable programmable completion features (you don't need to enable
## this, if it's already enabled in /etc/bash.bashrc and /etc/profile
## sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

## Oh-My-Posh - fancy prompt
## eval "$(oh-my-posh init bash)"
if command -v "oh-my-posh" &>/dev/null; then
  eval "$(oh-my-posh init bash --config $HOME/.cache/oh-my-posh/themes/catppuccin_mocha.omp.json)"
fi

## Fzf - fuzzy finder (nvim and yazi)
if command -v "fzf" &>/dev/null; then
  eval "$(fzf --bash)"
  source "$XDG_CONFIG_HOME/fzf/fzf-lib.sh"
fi

## Cargo - rust
if [ -d "$HOME/.cargo" ]; then
  . "$HOME/.cargo/env"
fi

## Asdf - elixir installer (like node's fnm/nvm)
# . <(asdf completion bash)
# ASDF_PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
# if [ -d "$FNM_PATH" ]; then
#   case ":$PATH:" in
#   *":$ASDF_PATH:"*) : ;; # already in PATH, do nothing
#   *) export PATH="$ASDF_PATH:$PATH" ;;
#   esac
# fi

## Yazi - enables changing the CWD when exiting
if command -v "yazi" &>/dev/null; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

# Runnit
if command -v "neofetch" &>/dev/null; then
  neofetch
fi
