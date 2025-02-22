#!/bin/bash

check_backend() {
    URL=$1
 
    echo "🔹 Running WhatWeb..."
    whatweb -a 3 --color=never "$URL" | tee scan_results.txt

    echo "🔹 Detecting server-side technology..."
    if grep -Eqi "PHP|ASP|JSP|Node.js|Django|Flask|Ruby on Rails|Spring|Laravel" scan_results.txt; then
        echo "[✅] Backend technology detected!"
    else
        echo "[❌] No backend technology found (might be static)."
    fi

    echo "🔹 Checking for database fingerprints..."
    if grep -Eqi "MySQL|MariaDB|PostgreSQL|MongoDB|SQLite|Oracle|MS-SQL" scan_results.txt; then
        echo "[✅] Database detected!"
    else
        echo "[❌] No database found."
    fi

    echo "🔹 Checking for CMS..."
    if grep -Eqi "WordPress|Drupal|Joomla|Magento|Shopify" scan_results.txt; then
        echo "[✅] CMS detected (likely uses a database)."
    else
        echo "[❌] No CMS detected."
    fi

    echo "🔹 Searching for API calls..."
    API=$(curl -s "$URL" | grep -E 'fetch\(|axios|XMLHttpRequest|api\/')
    if [[ ! -z "$API" ]]; then
        echo "[✅] API detected (likely dynamic)."
    else
        echo "[❌] No API calls found."
    fi

    echo "🔹 Checking for login pages..."
    LOGIN=$(curl -s "$URL" | grep -E 'login|signin|auth')
    if [[ ! -z "$LOGIN" ]]; then
        echo "[✅] Login page found!"
    else
        echo "[❌] No login page detected."
    fi

    echo "🔹 Testing query parameters..."
    if curl -sI "$URL?test=1" | grep -q "200"; then
        echo "[✅] Query parameters work (backend likely exists)."
    else
        echo "[❌] Query parameters do not work."
    fi

    echo "✅ Scan Complete!"
    echo "------------------------------------"
}

if [[ "$1" == "-url" && -n "$2" ]]; then
    check_backend "$2"
elif [[ "$1" == "-file" && -f "$2" ]]; then
    while IFS= read -r line; do
        check_backend "$line"
    done < "$2"
else
    echo "Usage:"
    echo "  $0 -url <URL>      # Scan a single URL"
    echo "  $0 -file <file>    # Scan multiple URLs from a file"
    exit 1
fi
