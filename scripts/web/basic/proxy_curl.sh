#!/bin/bash

PROXY="http://127.0.0.1:8080"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"

while IFS= read -r url; do
    # Skip empty lines
    [[ -z "$url" ]] && continue

#    echo "[+] Requesting: $url"
    curl --silent --proxy "$PROXY" -L --insecure -A "$UA" "$url" \
        -o /dev/null \
        -w "[%{http_code}] %{url_effective}\n"
done
