#!/bin/bash
# cname_enum.sh
# Usage: ./cname_enum.sh targets.txt

input_file="$1"

while read -r target; do
    # Skip empty lines
    [[ -z "$target" ]] && continue

    # Remove protocol (http:// or https://) if present
    clean_target=$(echo "$target" | sed -E 's~https?://~~')

    # Remove trailing slashes if any
    clean_target=$(echo "$clean_target" | sed 's:/*$::')

    cname=$(dig +short CNAME "$clean_target")
    if [[ -n "$cname" ]]; then
        echo "$clean_target -> $cname"
    fi
done < "$input_file"
