#!/usr/bin/env bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
THIS_PROG="$0"


function _vim_commands {
    local file="$1"
    local cmd_text="$2"
    local commands=""
    while IFS=$'\n' read -r line ; do
        if [ ! -z "$commands" ] ; then
            local commands="$commands |"
        fi
        local commands="$commands $line"
    done  <<<"$cmd_text"
    vim -s <(echo ":$commands") "$file"
}

function _vim_ultisnip_commands {
    filename="$1"
    shift

    cmds=$(cat <<EOF
execute "let g:expand=\"".substitute(g:UltiSnipsExpandTrigger, "<", "\\\\\\\\<", "g")."\""
execute "let g:next=\"".substitute(g:UltiSnipsJumpForwardTrigger, "<", "\\\\\\\\<", "g")."\""
$@
EOF
)

    echo _vim_commands "$filename" "$cmds"
    _vim_commands "$filename" "$cmds"
}

function fn_new {
    if [ $# -ne 1 ] ; then
        echo "USAGE: fn_new FN_FILE_NAME"
        return 1
    fi

    function escape {
        sed 's^\\^\\\\^g' <<<"$1" | sed 's^"^\\"^g'
    }

    local fn="$1"
    local fnpath="${SUPERDOTS}/dots/local/bash-sources/${fn}.sh"

    #local expand_pre='execute "let g:e=\"\\".g:UltiSnipsExpandTrigger."'
    local glet=$(escape 'let g:e="\".gUltiSnipsExpandTrigger')
    local expand_pre="execute \"let g:e=\\\"\\\\\".g:UltiSnipsExpandTrigger.\"\\\"\""
    local next_pre="execute \"let g:n=\\\"\\\\\".g:UltiSnipsJumpForwardTrigger.\"\\\"\""
    local expand='".g:e."'
    local next='".g:n."'

    if [ -e "${fnpath}" ] ; then
        local snippet='execute "normal Go\<cr>superdots-new_fn".g:expand'
    else
        local snippet='execute "normal 0isuperdots-new_fn_file".g:expand.g:expand.g:next'
    fi

    _vim_ultisnip_commands "$fnpath" "$snippet"

    if [ -e "$fnpath" ] ; then
        source "$fnpath"
        echo "new function ready to go!"
    else
        echo "did not source unsaved function file"
    fi
}

function fn_edit {
    if [ $# -ne 1 ] ; then
        echo "USAGE: edit_fn FN_FILE_NAME"
        return 1
    fi

    local fn="$1"
    local fnpath="${SUPERDOTS}/dots/local/bash-sources/${fn}.sh"

    if [ ! -e "${fnpath}" ] ; then
        fn_new $fn
        return $?
    fi

    vim "${fnpath}"

    if [ -f "${fnpath}" ] ; then
        source "${fnpath}"
        echo "new changes are ready for use"
    fi
}
