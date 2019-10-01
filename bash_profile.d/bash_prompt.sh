___dotfiles_prompt_status=()
___dotfiles_prompt_pipestatus=()
___dotfiles_prompt_started=()
___dotfiles_prompt_ended=()

function ___dotfiles_prompt_trap {
    if (( ! ${#___dotfiles_prompt_started[@]} || ${#___dotfiles_prompt_ended[@]} )); then
        IFS=$'\t' read -r -a ___dotfiles_prompt_started < <(date '+%s%t%H:%M:%S')
        ___dotfiles_prompt_ended=()
    fi
}

function ___dotfiles_prompt_command {
    local status=$? pipestatus=(${PIPESTATUS[@]})
    ___dotfiles_prompt_status=$status
    ___dotfiles_prompt_pipestatus=(${pipestatus[@]})
    if (( ${#___dotfiles_prompt_started[@]} && ! ${#___dotfiles_prompt_ended[@]} )); then
        IFS=$'\t' read -r -a ___dotfiles_prompt_ended < <(date '+%s%t%H:%M:%S')
    fi
    PS1="$(___dotfiles_prompt_ps1)"
    history -a
    history -c
    history -r
}

function ___dotfiles_prompt_ps1 {
    ___dotfiles_prompt_ps1_title
    ___dotfiles_prompt_ps1_result
    ___dotfiles_prompt_ps1_location
    ___dotfiles_prompt_ps1_prompt
}

function ___dotfiles_prompt_ps1_title {
    printf '\\[\\e]0;\\u@\\h:\\W\\a\\]'
}

function ___dotfiles_prompt_ps1_result {
    printf '\\n'
    ___dotfiles_prompt_ps1_result_status
    ___dotfiles_prompt_ps1_result_time
    printf '\\n'
}

function ___dotfiles_prompt_ps1_result_status {
    ___dotfiles_prompt_ps1_result_status_by_code $___dotfiles_prompt_status
    printf ' [ '
    local index
    for index in ${!___dotfiles_prompt_pipestatus[@]}; do
        (( ! $index )) || printf ' | '
        ___dotfiles_prompt_ps1_result_status_by_code ${___dotfiles_prompt_pipestatus[$index]}
    done
    printf ' ]'
}

function ___dotfiles_prompt_ps1_result_status_by_code {
    local code=$1
    local signal=
    (( $code <= 128 )) || signal="$(kill -l $(( $code - 128 )) 2>/dev/null)"
    if (( ! $code )); then
        printf '\\[\\e[32m\\]✔ %d\\[\\e[m\\]' $code
    elif [[ -z "$signal" ]]; then
        printf '\\[\\e[31m\\]✘ %d\\[\\e[m\\]' $code
    else
        printf '\\[\\e[31m\\]✘ %d:%s\\[\\e[m\\]' $code "$signal"
    fi
}

function ___dotfiles_prompt_ps1_result_time {
    (( ${#___dotfiles_prompt_started[@]} && ${#___dotfiles_prompt_ended[@]} )) || return 0
    printf ' took \\[\\e[4m\\]%'\''d s\\[\\e[m\\] \\[\\e[2m\\](%s - %s)\\[\\e[m\\]' \
        $(( ${___dotfiles_prompt_ended[0]} - ${___dotfiles_prompt_started[0]} )) \
        "${___dotfiles_prompt_started[1]}" \
        "${___dotfiles_prompt_ended[1]}"
}

function ___dotfiles_prompt_ps1_location {
    ___dotfiles_prompt_ps1_location_user
    ___dotfiles_prompt_ps1_location_host
    ___dotfiles_prompt_ps1_location_wd
    ___dotfiles_prompt_ps1_location_git
    printf '\\n'
}

function ___dotfiles_prompt_ps1_location_user {
    if [ "$EUID" -ne 0 ]; then
        printf '\\[\\e[36m\\]\\u\\[\\e[m\\]'
    else
        printf '\\[\\e[0;31m\\]\\u\\[\\e[m\\]'
    fi
}

function ___dotfiles_prompt_ps1_location_host {
    if [[ -z "${SSH_CONNECTION:-}" ]]; then
        printf '@\\[\\e[33m\\]\\h\\[\\e[m\\]'
    else
        printf '@\\[\\e[1;33m\\]\\H\\[\\e[m\\]'
    fi
}

function ___dotfiles_prompt_ps1_location_wd {
    if [[ "$PWD/" == "$HOME/"* ]]; then
        printf ':\\[\\e[34m\\]\\w\\[\\e[m\\]'
    else
        printf ':\\[\\e[1;34m\\]\\w\\[\\e[m\\]'
    fi
}

function ___dotfiles_prompt_ps1_location_git {
    type -t __git_ps1 &>/dev/null || return 0
    __git_ps1 ' on \\[\\e[35m\\]%s\\[\\e[m\\]'
}

function ___dotfiles_prompt_ps1_prompt {
    if [ "$EUID" -ne 0 ]; then
        printf '\\[\\e[36m\\]\\$\\[\\e[m\\] '
    else
        printf '\\[\\e[31m\\]\\$\\[\\e[m\\] '
    fi
}

trap "___dotfiles_prompt_trap" DEBUG
PROMPT_COMMAND="___dotfiles_prompt_command"
PROMPT_DIRTRIM=0
PS1='\$ '
PS2='> '
PS3='#? '
PS4='+ '

## Git bash prompt
## https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
if [ -f "$HOME/.dotfiles/bash_profile.d/git-prompt.sh" ]; then
  source "$HOME/.dotfiles/bash_profile.d/git-prompt.sh"
fi
GIT_PS1_DESCRIBE_STYLE="default"
GIT_PS1_HIDE_IF_PWD_IGNORED=true
GIT_PS1_SHOWCOLORHINTS=true
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_STATESEPARATOR=" "

