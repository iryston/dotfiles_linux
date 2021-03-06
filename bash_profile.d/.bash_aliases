## Custom aliases

## TMUX create new session or attach if exists
alias tms='tmux new-session -A -s "$(hostname -s)"'

## External IP
alias my-ip-external='dig @resolver1.opendns.com ANY myip.opendns.com +short -4 && dig @resolver1.opendns.com ANY myip.opendns.com +short -6'
## Internal IP
alias my-ip-internal="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"

## Beautify ls output
alias ls='ls --color -A --group-directories-first'

## Find broken symlinks
alias find-broken-links='find . -type l | while read f; do if [ ! -e "$f" ]; then ls -l "$f"; fi; done'

## Sort by line lenth
alias lsort='awk "{print length, \$0}" | sort -n | awk "{\$1=\"\"; print substr(\$0,2,length-1) }"'

## Compare directories
alias diff-dir='diff --ignore-file-name-case -qys'

## VIM aliases
alias v='nvim'
alias vn='vim -u NONE -U NONE -i NONE -N -n'
alias vu='vim +PlugUpgrade +PlugClean! +PlugInstall +PlugUpdate +qall'

## Local HTTP server (Python)
#alias httpserver='python -m SimpleHTTPServer 8000'
alias httpserver='python3 -m http.server'

## YouTube downloads
alias youtube-dl-nocache='youtube-dl --no-cache-dir'
alias youtube-dl-audio-only='youtube-dl --no-cache-dir --no-playlist --extract-audio --audio-quality 0'
alias youtube-dl-audio-playlist='youtube-dl --no-cache-dir --yes-playlist --extract-audio --audio-quality 0'

## Get local copy of site front
#alias site-sucker='wget -r -k -l 9 -p -E -nc'
alias site-sucker='wget --no-check-certificate -e robots=off -r -k -l 9 -p -E -nc'

## Docker4Drupal aliases
# alias drush='make drush'
# alias composer='make composer'

