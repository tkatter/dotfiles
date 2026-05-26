#!/usr/bin/env bash
##
# Interactive search. Use fzf as an interface for ripgrep.
# Usage: `ff` or `ff <folder>`.

# credit to somewhere on the fzf example page
function ff() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            # No selection. Open the current line in Vim.
            nvim {1} +{2}
          else
            # Build quickfix list for the selected items.
            nvim +cw -q {+f}
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)
