#!/usr/bin/env bash


function _vim_file_completion {
    plugin_name="${1:-local}"
    for vim_name in "${SUPERDOTS}"/dots/"$plugin_name"/vim-sources/*.vim ; do
        if [[ $vim_name =~ '*' ]] ; then
            continue
        fi

        if [ -z "$1" ] ; then
            basename "${vim_name}" | sed 's/\.vim//'
        else
            echo "$plugin_name/$(basename "${vim_name}" | sed 's/\.vim//')"
        fi
    done

    if [ -z "$1" ] ; then
        # now do all of the non-local plugin/file names
        for plugin_path in $(ls "${SUPERDOTS}"/dots) ; do
            if [ "$plugin_path" == "local" ] || [ "$plugin_path" == "system" ] ; then
                continue
            fi
            _vim_file_completion "$plugin_path"
        done
    fi
}

function _ensure_editor {
    if [ -z "$EDITOR" ] ; then
        superdots-warn "EDITOR is not set"
        superdots-warn "Please set the EDITOR environment variable"
        superdots-warn "E.g."
        superdots-warn "    export EDITOR=vim"
        superdots-warn ""
        return 1
    fi
}

sd::completion::add vim_new _vim_file_completion
function vim_new {
    if [ $# -ne 1 ] ; then
        echo "USAGE: vim_new VIM_FILE_NAME"
        return 1
    fi

    if ! _ensure_editor ; then
        return 1
    fi

    local vim="$1"
    local vim_path=$(_get_vim_path "$vim")

    $EDITOR $vim_path
    
    if [ -e "$vim_path" ] ; then
        echo "new vim ready to go!"
    else
        echo "file was not saved"
    fi
}


sd::completion::add vim_fn_new _vim_file_completion
function vim_fn_new {
    if [ $# -ne 1 ] ; then
        echo "USAGE: vim_new VIM_FILE_NAME"
        return 1
    fi

    if ! _ensure_editor ; then
        return 1
    fi

    function escape {
        sed 's^\\^\\\\^g' <<<"$1" | sed 's^"^\\"^g'
    }

    local vim="$1"
    local vim_path=$(_get_vim_path "$vim")

    #local expand_pre='execute "let g:e=\"\\".g:UltiSnipsExpandTrigger."'
    local glet=$(escape 'let g:e="\".gUltiSnipsExpandTrigger')
    local expand_pre="execute \"let g:e=\\\"\\\\\".g:UltiSnipsExpandTrigger.\"\\\"\""
    local next_pre="execute \"let g:n=\\\"\\\\\".g:UltiSnipsJumpForwardTrigger.\"\\\"\""
    local expand='".g:e."'
    local next='".g:n."'

    if [ -e "${vim_path}" ] ; then
        local snippet='execute "normal Go\<cr>superdots-vim_new_fn".g:expand'
    else
        local snippet='execute "normal 0isuperdots-vim_new_file".g:expand'
    fi

    _vim_ultisnip_commands "$vim_path" "$snippet"

    if [ -e "$vim_path" ] ; then
        superdots-info "new vim function ready to go!"
    else
        superdots-warn "file was not saved"
    fi
}

function _get_vim_path {
    # remove the leading slash
    local vim="$1"

    if [[ "$vim" =~ / ]] ; then
        local plugin=$(sed 's^/.*^^' <<<"$vim")
        local vim=$(sed 's^.*/^^' <<<"$vim")
        local vim_path="${SUPERDOTS}/dots/$plugin/vim-sources/${vim}.vim"
    else
        local vim_path="${SUPERDOTS}/dots/local/vim-sources/${vim}.vim"
    fi
    echo "$vim_path"
}

sd::completion::add vim_edit _vim_file_completion -o nosort
function vim_edit {
    if [ $# -ne 1 ] ; then
        echo "USAGE: vim_edit VIM_FILE_NAME"
        return 1
    fi

    if ! _ensure_editor ; then
        return 1
    fi

    local vim="$1"
    local vim_path=$(_get_vim_path "$vim")

    if [ ! -e "${vim_path}" ] ; then
        vim_new $vim
        return $?
    fi

    $EDITOR $vim_path

    if [ -f "${vim_path}" ] ; then
        superdots-info "new changes are ready for use"
    else
        superdots-warn "file was not saved"
    fi
}
