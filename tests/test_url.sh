#!/bin/bash

set -e

URL=$1
if [ -z "$URL" ]
then
    echo "Syntax: $0 <URL> "
    echo "Examples:"
    echo "    $0 http://google.com/"
    echo ""
    exit 1
fi

test_url () {
    curl -sL \
    -w "%{http_code}\\n" \
    "$1" \
    -o /dev/null \
    --connect-timeout 3 \
    --max-time 5
}

if [ $(test_url "$URL") == "200" ];
then
    echo "OK"
    exit 0
else
    echo "Not OK"
    exit 1
fi
