#!/usr/bin/env bash


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

