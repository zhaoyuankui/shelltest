#!/bin/bash

declare -i cur_line=0

function expect_log() {
    if [ $# -ne 2 ]; then
        return 1
    fi
    declare -i start=`date '+%s'`
    declare -i timeout=$((start + 5))
    _sleep=`which usleep`
    if [ ! "$_sleep" ]; then 
        _sleep="sleep 1"
    else
        _sleep="$_sleep 100"
    fi
    while true; do 
        declare -i start_line=$((cur_line + 1))
        match=`sed -n "$start_line"',$p' "$1" | grep -n "$2" | head -1`
        if [ "$match" ]; then
            declare -i line=`echo $match | awk -F: '{print $1}'`
            cur_line=$((cur_line+line))
            return 0
        fi
        $_sleep
        declare -i now=`date '+%s'`
        if [ $now -gt $timeout ]; then 
            break;
        fi
    done
    return 1
}

function expect_no_log() {
    declare -i start_line=$((cur_line + 1))
    match=`sed -n "$start_line"',$p' "$1" | grep -n "$2" | head -1`
    if [ ! "$match" ]; then
        return 0
    fi
    fail "unexpected '$2' in $1"
}

function fail() {
    echo "Failed for " ${@}
    exit 1
}

function exist() {
    if [ -f "$1" ]; then
        return 0
    fi
    fail "file $1 not exist"
}

function not_exist() {
    if [ -f "$1" ]; then
        fail "file $1 exists"
    fi
    return 0
}

function dir_exist() {
    if [ -d "$1" ]; then
        return 0
    fi
    fail "directory $1 not exist"
}

function dir_not_exist() {
    if [ ! -d "$1" ]; then
        return 0
    fi
    fail "directory $1 exist"
}

function dir_empty() {
    if [ -d "$1" ] && [ ! "`ls $1`" ]; then
        return 0
    fi
    fail "directory $1 not empty"
}

function success() {
    echo SUCCESS ${@}
}

function file_equal() {
    if [ $# -ne 2 ]; then
        fail "file $1 $2 not equal"
    fi
    if [ `diff "$1" "$2" | wc -l` -ne 0 ]; then
        fail "file $1 $2 not equal"
    fi
    return 0
}

function file_equal_unorder() {
    if [ $# -ne 2 ]; then
        fail "file $1 $2 not equal"
    fi
    if [ `cat "$1" "$2" | sort | uniq -u | wc -l` -ne 0 ]; then
        fail "file $1 $2 not equal"
    fi
    return 0
}

function file_unequal_unorder() {
    if [ $# -ne 2 ]; then
        fail "file missing in compare, files: [${@}]"
    fi
    if [ `cat "$1" "$2" | sort | uniq -u | wc -l` -eq 0 ]; then
        fail "file $1 $2 equal"
    fi
    return 0
}
