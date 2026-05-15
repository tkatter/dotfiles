# shellcheck disable=SC2148
# shellcheck disable=SC1090
# shellcheck disable=SC1091

## XDG Base Directories
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="$XDG_DATA_HOME:$XDG_DATA_DIRS"
export GPG_TTY
GPG_TTY=$(tty)

## Export EDITOR env variable
export EDITOR
if command -v "nvim" &>/dev/null; then
  EDITOR="$(command -v nvim)"
elif command -v "vim" &>/dev/null; then
  EDITOR="$(command -v vim)"
elif command -v "vi" &>/dev/null; then
  EDITOR="$(command -v vi)"
else
  EDITOR="nano" # last resort
fi

## Export `$HOME/.local/bin`
LOCAL_BIN="$HOME/.local/bin"
if [ -d "$LOCAL_BIN" ]; then
  case ":$PATH:" in
  *":$LOCAL_BIN:"*) : ;; # already in PATH, do nothing
  *) export PATH="$LOCAL_BIN:$PATH" ;;
  esac
fi

[ -d "$HOME/.zig" ] && export PATH="$PATH:$HOME/.zig"
# export PATH="$PATH:$HOME/.zig/15.2"

## History sync between shells
PROMPT_COMMAND='history -a; history -n'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## ssh-agent logic
## Need because of i3 as DE, not needed if using Cinnamon or such
agent_env="$HOME/.ssh/agent-env"
## Ensure agent-env exists
[ -f "$agent_env" ] || ssh-agent -s >"$agent_env"

## Load it, then test if the agent is alive
source "$agent_env" &>/dev/null || { ssh-agent -s >"$agent_env" && . "$agent_env" &>/dev/null; }

if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
  ssh-agent -s >"$agent_env"
  . "$agent_env" &>/dev/null
fi

## Don't put duplicate lines or lines starting with space in the history.
## See bash(1) for more options
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

## Check the window size after each command and, if necessary,
## update the values of LINES and COLUMNS.
shopt -s checkwinsize
## Append to the history file, don't overwrite it
shopt -s histappend
## If set, the pattern "**" used in a pathname expansion context will
## match all files and zero or more directories and subdirectories.
shopt -s globstar

## Make less more friendly for non-text input files, see lesspipe(1)
if [ -x /usr/bin/lesspipe ]; then
  eval "$(SHELL=/bin/sh lesspipe)"
elif [ -x /usr/bin/lesspipe.sh ]; then
  eval "$(SHELL=/bin/sh lesspipe.sh)"
fi

## Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  (xterm-color | *-256color | xterm-ghostty)
    color_prompt=1
    ;;
  (*)
    color_prompt=0
    ;;
esac

## We want color baby
force_color_prompt=0

if ((force_color_prompt)); then
  if [ -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then
    ## We have color support; assume it's compliant with Ecma-48
    ## (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    ## a case would tend to support setf rather than setaf.)
    color_prompt=1
  else
    color_prompt=0
  fi
fi

if ((color_prompt)); then
  PS1="\
\[\033[00;38;5;147m\](\h)\[\033[00m\]\
\[\033[01;38;5;219m\]\u\[\033[00m\] \
\[\033[02;38;5;105m\]\w\[\033[00m\] \
$(git branch --show-current 2>/dev/null) \
\[\033[01;38;5;219m\]\$\[\033[00m\] "

  function update_prompt() {
    local ref fmt glyph
    glyph='\uE725'
    ref="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [ -n "$ref" ]; then
      fmt="$(printf '\[\033[00;38;5;147m\]%b %s\[\033[00m\] ' "$glyph" "$ref")"
    else
      fmt=""
    fi

    PS1="\
\[\033[00;38;5;147m\](\h)\[\033[00m\]\
\[\033[01;38;5;219m\]\u\[\033[00m\] \
\[\033[02;38;5;105m\]\w\[\033[00m\] $fmt\
\[\033[01;38;5;219m\]\$\[\033[00m\] "
  }

  export PROMPT_COMMAND="update_prompt"
else
  PS1='(\h)\u \w \$ '
fi

## Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  if [ -r ~/.dircolors ]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi

## Add an "alert" alias for long running commands.  Use like so:
##   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

## Source .bash_aliases
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

## Enable programmable completion features (you don't need to enable
## this, if it's already enabled in /etc/bash.bashrc and /etc/profile
## sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ $PS1 && -f /usr/local/share/bash-completion/bash_completion.sh ]]; then
    source /usr/local/share/bash-completion/bash_completion.sh
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
fi

## Fzf - fuzzy finder (nvim and yazi)
if command -v "fzf" &>/dev/null; then
  eval "$(fzf --bash)"
  [ -f "$XDG_CONFIG_HOME/fzf/fzf-lib.sh" ] && source "$XDG_CONFIG_HOME/fzf/fzf-lib.sh"
fi

## Yazi - enables changing the CWD when exiting
if command -v "yazi" &>/dev/null; then
  function y() {
    local tmp cwd

    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    trap 'rm -f -- $tmp' RETURN

    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd" || return
  }
fi

# Runnit
if command -v "neofetch" &>/dev/null; then
  neofetch
elif command -v "fastfetch" &>/dev/null; then
  fastfetch
fi
. "$HOME/.cargo/env"
