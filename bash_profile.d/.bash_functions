#!/usr/bin/env bash

# Create a new directory and enter it.
mkd () {
  mkdir -p "$@" && cd "$_";
}

# Determine size of a file or total size of a directory.
fsize () {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* ./*;
  fi;
}

# Create a data URL from a file.
dataurl () {
  local mimeType=$(file -b --mime-type "$1");
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8";
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# fshow - git commit browser
fshow-git-log() {
git log --graph --color=always \
  --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
  --bind "ctrl-m:execute:
  (grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
  {}
  FZF-EOF"
}

# Search and jump to git branch
fbranch() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) && \
    branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) && \
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

fbuku() {
  # save newline separated string into an array
  # mapfile -t website <<< "$(buku -p -f 5 | column -ts$'\t' | fzf --multi)"

  while IFS='' read -r line || [[ -n "$line" ]]; do
    website=("$line")
  done <<< "$(buku -p -f 5 | column -ts$'\t' | fzf --multi)"

  # open each website
  for i in "${website[@]}"; do
    index="$(echo "$i" | awk '{print $1}')"
    buku -p "$index"
    buku -o "$index"
  done
}

fvim() {
  local IFS=$'\n'
  local files=($(fzf --preview="cat {}" --preview-window=right:60%:wrap --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}
# bind -x '"\C-p": fvim'

tmf() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) && \
    tmux $change -t "$session" || echo "No sessions found."
}


