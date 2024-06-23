#!/bin/bash
shopt -s expand_aliases
source ~/.bash_profile

LOG_PATH=log/log.log

log() {
    local type=$1
    local shell_name=$2
    local message=$3
    date_time="$(date '+%Y-%m-%d %H:%M:%S.%3N')"

    echo -e "[$type] $date_time $shell_name: $message" | tee -a log/log.log
}

log_info() {
    log INFO $0 "$*"
}

log_error() {
    log ERRO $0 "$*"
}