#!/usr/bin/env bash


function _vim_ultisnip_commands {
    filename="$1"
    shift

    cmds=$(cat <<EOF
execute "let g:expand=\"".substitute(g:UltiSnipsExpandTrigger, "<", "\\\\\\\\<", "g")."\""
execute "let g:next=\"".substitute(g:UltiSnipsJumpForwardTrigger, "<", "\\\\\\\\<", "g")."\""
$@
EOF
)

    _vim_commands "$filename" "$cmds"
}

function _ensure_editor {
    if ! superdots-ensure-deps vim ; then
        superdots-warn "vim not found. Please install vim"
        return 1
    fi
}

function fn_new {
    if [ $# -ne 1 ] ; then
        echo "USAGE: fn_new FN_FILE_NAME"
        return 1
    fi

    if ! _ensure_editor ; then
        return 1
    fi

    function escape {
        sed 's^\\^\\\\^g' <<<"$1" | sed 's^"^\\"^g'
    }

    local fn="$1"
    local fnpath=$(_get_fn_path "$fn")

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
        superdots-info "new function ready to go!"
    else
        superdots-warn "did not source unsaved function file"
    fi
}

function fn_edit {
    if [ $# -ne 1 ] ; then
        echo "USAGE: fn_edit FN_FILE_NAME"
        return 1
    fi

    if ! _ensure_editor ; then
        return 1
    fi

    local fn="$1"
    local fnpath=$(_get_fn_path "$fn")

    if [ ! -e "${fnpath}" ] ; then
        fn_new $fn
        return $?
    fi

    vim "${fnpath}"

    if [ -f "${fnpath}" ] ; then
        source "${fnpath}"
        superdots-info "new changes are ready for use"
    else
        superdots-warn "file was not saved"
    fi
}
