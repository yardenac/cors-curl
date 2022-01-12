#!/usr/bin/bash

usage() {
    echo "USAGE: cors-curl [--ua=user-agent] [curl-options] [url ...]"
    exit
}

urls=() curlopts=() ua='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36'
(( "${#args[@]}" )) && usage
for arg; do
    if [[ "$arg" =~ ^https?:// ]]; then
        urls+=("$arg")
    else
        case "$arg" in
            --ua=*) ua="${arg#--ua=}";;
            --help) usage;;
            *) curlopts+=("$arg");;
        esac
    fi
done
main() {
    for url in "${urls[@]}"; do
        do_download "$url"
    done
    exit
}
do_download() {
    local schema="${1%%://*}"
    local without_schema="${1#*://}"
    local domain="${without_schema%%/*}"
    browser=(
        -A "$ua" \
        -H "Origin: ${schema}://${domain}" \
        -e "${schema}://${domain}/" \
    )
    curl "${browser[@]}" --verbose -X OPTIONS \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: X-Requested-With" \
     "${curlopts[@]}" "$1"
    curl "${browser[@]}" --verbose -O -C- "${curlopts[@]}" "$1"
}
main
