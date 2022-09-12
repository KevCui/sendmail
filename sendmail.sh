#!/usr/bin/env bash
#
# Send anonymous email from terminal
#
#/ Usage:
#/   ./sendmail.sh -t <to_address> [-s <subject>|-m <message>]
#/
#/ Options:
#/   -t               required, recipient mail address
#/   -s               optional, subject
#/   -m               optional, message
#/   -h | --help      display this help message

set -e
set -u

usage() {
    printf "%b\n" "$(grep '^#/' "$0" | cut -c4-)" >&2 && exit 0
}

set_var() {
    _TMP_FILE=$(mktemp)
    _HOST="https://tempr.email"
    _API="${_HOST}/application/api"
    _SID="$(tr -dc 'a-z0-9' < /dev/urandom | head -c26)"
    _COOKIE="LocalPart=${_SID}; DomainId=1; sid=${_SID}"
    _FROM_ADDRESS="${_SID}@tempr.email"
}

set_command() {
    _CURL="$(command -v curl)" || command_not_found "curl" "https://curl.haxx.se/download.html"
    _VIU="$(command -v viu)" || command_not_found "viu" "https://github.com/atanunq/viu"
}

set_args() {
    expr "$*" : ".*--help" > /dev/null && usage
    _MAIL_MESSAGE="$(tr -dc 'a-z0-9' < /dev/urandom | head -c128)"
    _MAIL_SUBJECT="$(tr -dc 'a-z0-9' < /dev/urandom | head -c16)"
    while getopts ":ht:s:m:" opt; do
        case $opt in
            t)
                _TO_ADDRESS="$OPTARG"
                ;;
            s)
                _MAIL_SUBJECT="$OPTARG"
                ;;
            m)
                _MAIL_MESSAGE="$OPTARG"
                ;;
            h)
                usage
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage
                ;;
        esac
    done
}

print_info() {
    # $1: info message
    printf "%b\n" "\033[32m[INFO]\033[0m $1" >&2
}

print_error() {
    # $1: error message
    printf "%b\n" "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

command_not_found() {
    # $1: command name
    # $2: installation URL
    if [[ -n "${2:-}" ]]; then
        print_error "$1 command not found! Install from $2"
    else
        print_error "$1 command not found!"
    fi
}

check_var() {
    if [[ -z "${_TO_ADDRESS:-}" ]]; then
        print_error "Missing recipient email address: -t <to_address>"
    fi
}

cleanup() {
    if [[ -n "${_TMP_FILE:-}" && -f "$_TMP_FILE" ]]; then
        rm -f "$_TMP_FILE"
    fi
}

encode_url() {
    # $1: input string
    # code from https://stackoverflow.com/a/10660730
    local string="$1"
    local strlen=${#string}
    local encoded pos c o

    encoded=""
    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * )  printf -v o '%%%02X' "'$c"
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}

account_login() {
    $_CURL -sS "${_HOST}/en/" \
        -H "Cookie: ${_COOKIE}" \
        --data-raw "LocalPart=${_SID}&DomainType=public&DomainId=1&PrivateDomain=&Password=&LoginButton=Log+in+%26+check+e-mails&CopyAndPaste=${_FROM_ADDRESS}" \
        &> /dev/null
}

enter_captcha() {
    local c=""
    $_CURL -sS "${_API}/secureCaptcha.php?sid=${_SID}&small=1" \
        -H "Cookie: ${_COOKIE}" \
        -o "$_TMP_FILE"

    [[ ! -s "$_TMP_FILE" ]] && print_error "Failed to fetch Captcha image"

    $_VIU "$_TMP_FILE" >&2
    while [[ "$c" == "" ]]; do
        read -rp "Enter captcha letters (case insensitive): " c
    done
    echo "$c"
}

send_mail() {
    local m s c s
    m="$(encode_url "$_MAIL_MESSAGE")"
    s="$(encode_url "$_MAIL_SUBJECT")"
c="$(enter_captcha)"

    s=$($_CURL -sS "${_HOST}/en/sendmail.htm" -H "Cookie: ${_COOKIE}" --data-raw "FromAddress=${_FROM_ADDRESS}&ToAddress=${_TO_ADDRESS}&Subject=${s}&Message=${m}&secureCaptcha=${c}&SendButton=Send+e-mail" \
    | grep -E '"boxRed"|"boxGreen"' \
    | sed -E 's/.*boxRed">//' \
    | sed -E 's/.*boxGreen">//' \
    | sed -E 's/<\/div>.*//')

    [[ "$s" =~ \[[0-9]+\] ]] && print_error "$s"
    print_info "$s"
}

main() {
    set_args "$@"
    set_command
    set_var
    check_var

    account_login
    send_mail
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    trap cleanup INT
    trap cleanup EXIT
    main "$@"
fi
