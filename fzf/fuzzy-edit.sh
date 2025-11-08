#!/usr/bin/env bash
# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Exit if there's no match (--exit-0)

fe() {
  fzf --query="$1" \
    --scheme=path \
    --multi \
    --exit-0 \
    --preview="bat --color=always --style numbers {}" \
    --bind "one:become(${EDITOR} {})" \
    --bind "enter:become(${EDITOR} {})"
}
