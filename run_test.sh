#!/bin/bash

source ./utils.sh

function run_test() {
    echo "Run test $1"
    source "./$1"
    run_fun _init
    run
    run_fun _clean
    unset _init
    unset _clean
    unset run
}

function do_clean() {
    if [ $? -eq 0 ]; then
        return
    fi
    run_fun _clean
}

function run_fun() {
    if [ $# -lt 1 ]; then
        return
    fi
    if [ "$(type -t $1)" = 'function' ]; then
        ${@}
    fi
}

trap do_clean EXIT

declare -a tests=("${@}")
if [ ${#tests} -eq 0 ]; then
    tests=(`ls test_*.sh`)
fi

for t in ${tests[@]}; do
    run_test $t
    if [ $? -eq 0 ]; then
        success $t
    fi
done

