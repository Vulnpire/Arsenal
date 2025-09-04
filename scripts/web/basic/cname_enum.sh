#!/bin/bash
# cname_enum.sh
# Usage: cname_enum.sh targets.txt

input_file="$1"

while read -r target; do
    cname=$(dig +short CNAME "$target")
    if [[ -n "$cname" ]]; then
        echo "$target -> $cname"
    fi
done < "$input_file"
