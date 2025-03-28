#!/bin/bash

# Ensure input is provided
if [ $# -ne 1 ]; then
    echo "Usage: cat result.txt | ./script.sh <domain_or_file>"
    exit 1
fi

INPUT="$1"

# Check if INPUT is a file or a single domain
if [ -f "$INPUT" ]; then
    PATTERN=$(tr '\n' '|' < "$INPUT" | sed 's/|$//')
else
    PATTERN="$INPUT"
fi

# Process input line by line
awk -v pattern="$PATTERN" '
    /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {ip=$1}  # Capture standalone IP addresses
    /Hostnames:/ && $0 ~ pattern {print ip}     # Print IP if hostname matches any domain
'
