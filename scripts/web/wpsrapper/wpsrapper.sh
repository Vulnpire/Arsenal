#!/bin/bash

CONFIG_PATH="$HOME/.config/wpsrapper/config.txt"

get_random_api_key() {
    if [[ ! -f "$CONFIG_PATH" ]]; then
        echo "ERROR: API key configuration file not found at $CONFIG_PATH"
        exit 1
    fi

    mapfile -t API_KEYS < "$CONFIG_PATH"
    if [[ ${#API_KEYS[@]} -eq 0 ]]; then
        echo "ERROR: No API keys found in the configuration file."
        exit 1
    fi

    RANDOM_API_KEY=${API_KEYS[RANDOM % ${#API_KEYS[@]}]}
    echo "$RANDOM_API_KEY"
}

update_wpscan() {
    echo "Updating WPScan..."
    sudo gem update wpscan
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to update WPScan. Please check your gem installation."
        exit 1
    fi
    echo "WPScan updated successfully."
}

usage() {
    echo "Usage: cat urls.txt | wpsrapper <wpscan options>"
    echo "Example: cat urls.txt | wpsrapper --enumerate u"
    exit 1
}

if [[ -t 0 ]]; then
    usage
fi

URLS=()
while IFS= read -r url; do
    if [[ "$url" =~ ^http(s)?:// ]]; then
        URLS+=("$url")
    else
        echo "WARNING: Skipping invalid URL: $url"
    fi
done

if [[ ${#URLS[@]} -eq 0 ]]; then
    echo "ERROR: No valid URLs provided. Make sure to pipe valid URLs to the script."
    exit 1
fi

update_wpscan

for url in "${URLS[@]}"; do
    API_KEY=$(get_random_api_key)
    echo "Running WPScan for $url with randomized API key."

    wpscan --url "$url" --api-token "$API_KEY" "${@:1}"
    if [[ $? -ne 0 ]]; then
        echo "ERROR: WPScan failed for $url. Check log for details."
    fi
done

echo "All scans completed."