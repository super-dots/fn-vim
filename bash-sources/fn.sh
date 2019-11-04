#!/usr/bin/env bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
THIS_PROG="$0"


function fn_new {
    if [ $# -ne 1 ] ; then
        echo "USAGE: fn_new FN_FILE_NAME"
        return 1
    fi

    local fn="$1"
    local fnpath="${SUPERDOTS}/dots/local/bash-sources/${fn}.sh"

    if [ -e "${fnpath}" ] ; then
        local start_cmd="Go\\<cr>"
        local snippet="superdots-new_fn\\<c-l>"
    else
        local start_cmd="0i"
        local snippet="superdots-new_fn_file\\<c-l>\\<c-l>\\<c-j>"
    fi

    vim \
        -s <(echo -e ':execute "normal '${start_cmd}${snippet}'"') \
        "$fnpath"
    
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
