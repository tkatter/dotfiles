#!/usr/bin/env bash
# Loads all of the custom fzf commands

# Prefer full-height
export FZF_DEFAULT_OPTS="--style full \
  --layout default
  --walker-skip .local/state,.local/share,.Private,.asdf,.cache,target,node_modules,.cargo,.steam,.var,.rustup,.hex,.icons,_build,.mozilla,.elixir_ls,deps,.git,.npm,assets,.pgadmin,.ecryptfs,.gnupg,.linuxmint \
  --border --padding 1,2 \
  --border-label ' FZF ' --input-label ' Input ' --header-label ' File Type ' \
  --header-lines 0 \
  --bind 'result:transform-list-label:if [[ -z \$FZF_QUERY ]]; then echo \" \$FZF_MATCH_COUNT items \" else echo \" \$FZF_MATCH_COUNT matches for [\$FZF_QUERY] \" fi' \
  --bind 'focus:transform-preview-label:[[ -n {} ]] && printf \" Previewing [%s] \" {}' \
  --bind 'focus:+transform-header:file --brief {} || echo \"No file selected\"' \
  --color 'border:#aaaaaa,label:#cccccc' \
  --color 'preview-border:#9999cc,preview-label:#ccccff' \
  --color 'list-border:#669966,list-label:#99cc99' \
  --color 'input-border:#996666,input-label:#ffcccc' \
  --color 'header-border:#6699cc,header-label:#99ccff'"

# --preview 'fzf-preview.sh {}' \
# Using highlight (http://www.andre-simon.de/doku/highlight/en/highlight.html)
export FZF_CTRL_T_OPTS="--preview '(bat --color=always --style numbers {} || tree -C {}) 2> /dev/null | head -200'"

# Bind '?' to view full commands that don't fit in the list
export FZF_CTRL_R_OPTS="--style minimal \
  --scheme=history \
  --preview \"echo {} | cut -w -f 2-\" \
  --preview-window down:3:hidden:wrap \
  --bind 'focus:transform-preview-label:printf \"\"' \
  --bind 'focus:+transform-header: echo' \
  --bind '?:toggle-preview'"

export FZF_ALT_C_OPTS="--preview 'tree -C -L 4 {} | head -200' \
  --scheme=path \
  --walker dir,follow,hidden"

fzf_dir="$XDG_CONFIG_HOME/fzf"

source "${fzf_dir}/fzf-select-paths.sh"
source "${fzf_dir}/fuzzy-edit.sh"
source "${fzf_dir}/interactive-search.sh"
source "${fzf_dir}/fzf-man.sh"
