## Void ZSH Theme
## Fork of https://gist.github.com/agnoster/3712874

DEFAULT_USER="tong"
CURRENT_BG='NONE'

## Special Powerline characters
() {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    SEGMENT_SEPARATOR=$'\ue0b0'
}

## Begin a segment,takes two optional arguments, background and foreground
prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
        echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
    else
        echo -n "%{$bg%}%{$fg%} "
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

##### Prompt components

## Time: H:M
prompt_time() {
    prompt_segment white black "$(date +%R:%S)"
}

## Context: user@hostname
prompt_context() {
    if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        prompt_segment black default "%(!.%{%F{yellow}%}.)$USER@%m"
    else
        prompt_segment black default ""
    fi
}

## Dir: current working directory
prompt_dir() {
    case "$PWD" in
        # $HOME*)
        #     prompt_segment blue black '%~'
        # ;;
        $HOME/doc*)
            prompt_segment blue black ' %~'
        ;;
        $HOME/downloads*)
            prompt_segment blue black '  %~'
        ;;
        $HOME/music*)
            prompt_segment blue black '  %~'
        ;;
        $HOME/img*)
            prompt_segment blue black '  %~'
        ;;
        $HOME/videos*)
            prompt_segment blue black '  %~'
        ;;
        $HOME/.config*)
            prompt_segment blue black '  %~'
        ;;
    	$HOME/dev*)
            prompt_segment black grey ' %~'
        ;;
        $HAXELIB_PATH)
            prompt_segment yellow black '●  %~'
        ;;
        $HAXELIB_PATH/*)
            local lib=$(basename "$PWD")
            local version=""
            if [ -f .current ]; then
                version=$(cat .current)
                if [[ $version == *"dev"* ]]; then
                    version=$(cat .dev)
                fi
            else
                if [ -f .dev ]; then
                    version=$(cat .dev)
                fi
            fi
            prompt_segment yellow black "  haxelib/$lib"
            prompt_segment black yellow "$version"

            #if [ -f "$PWD/run.n" ]; then
            #    prompt_segment black yellow " "
            #fi
        ;;
    	*)
            prompt_segment white black '%~'
        ;;
    esac
}

## Git: branch/detached head, dirty status
prompt_git() {

    local PL_BRANCH_CHAR
    () {
        local LC_ALL="" LC_CTYPE="en_US.UTF-8"
        PL_BRANCH_CHAR=$''         # 
    }

    local ref dirty mode repo_path
    repo_path=$(git rev-parse --git-dir 2>/dev/null)

    if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then

        dirty=$(parse_git_dirty)
        ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

        if [[ -n $dirty ]]; then
            prompt_segment yellow black
        else
            prompt_segment green black
        fi

        if [[ -e "${repo_path}/BISECT_LOG" ]]; then
            mode=" <B>"
        elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
            mode=" >M<"
        elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
            mode=" >R>"
        fi

        setopt promptsubst
        autoload -Uz vcs_info

        zstyle ':vcs_info:*' enable git
        zstyle ':vcs_info:*' get-revision true
        zstyle ':vcs_info:*' check-for-changes true
        zstyle ':vcs_info:*' stagedstr 'ཧ'
        zstyle ':vcs_info:*' unstagedstr ''
        zstyle ':vcs_info:*' formats ' %u%c'
        zstyle ':vcs_info:*' actionformats ' %u%c'

        vcs_info

        echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
    fi
}

## Virtualenv: current working virtualenv
prompt_virtualenv() {
    local virtualenv_path="$VIRTUAL_ENV"
    if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
        prompt_segment blue black "(`basename $virtualenv_path`)"
    fi
}

## Status:
## - was there an error
## - am I root
## - are there background jobs?
prompt_status() {
    local symbols
    symbols=()
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"
    if [[ -n "$symbols"  ]]; then
        prompt_segment black default "$symbols"
    fi
}

## End the prompt, closing any open segments
prompt_end() {
    if [[ -n $CURRENT_BG ]]; then
        echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
    else
        echo -n "%{%k%}"
    fi
    echo -n "%{%f%}"
    CURRENT_BG=''
}

prompt_history() {
    local hist_no="${blue_op}%h${blue_cp}"
    prompt_segment black grey "$hist_no"
}

build_prompt() {
    RETVAL=$?
    prompt_time
    prompt_virtualenv
    prompt_context
    #prompt_history
    prompt_dir
    prompt_git
    prompt_status
    prompt_end
}
PROMPT='%{%f%b%k%}$(build_prompt) '

build_rprompt() {
    #RETVAL=$?
    prompt_history
    prompt_time
    #prompt_end
}
# RPROMPT='[%*]'
# RPROMPT="$(date +%R:%S)"
#RPROMPT='$(build_rprompt)'