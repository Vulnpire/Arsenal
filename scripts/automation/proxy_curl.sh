#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: bash $0 <file_with_hosts>"
    exit 1
fi

hosts_file="$1"

proxy="http://127.0.0.1:8080"

if [ ! -f "$hosts_file" ]; then
    echo "Error: File '$hosts_file' not found!"
    exit 1
fi

while IFS= read -r host; do
    curl -s --proxy "$proxy" "$host"
done < "$hosts_file"
