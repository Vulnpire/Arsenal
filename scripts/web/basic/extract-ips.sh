#!/bin/bash

# Ensure input is provided
if [ $# -lt 1 ]; then
    echo "Usage: echo <domain_or_file> | ./extract-ips.sh <domain_or_file> [-v]"
    exit 1
fi

INPUT="$1"
VERBOSE=""

# Check for -v flag
if [ "$2" == "-v" ]; then
    VERBOSE="true"
fi

# Build matching pattern
if [ -f "$INPUT" ]; then
    PATTERN=$(tr '\n' '|' < "$INPUT" | sed 's/|$//')
else
    PATTERN="$INPUT"
fi

# Debugging: print pattern
if [ "$VERBOSE" == "true" ]; then
    echo "Using pattern: $PATTERN"
fi

# Main logic: process each IP/domain from stdin line-by-line
while read -r target; do
    sleep 1  # Enforce Shodan's 1 request/second rate limit

    # Get result from shodan
    output=$(shodan host "$target")

    # Extract IP (first IP line)
    ip=$(echo "$output" | awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print $1; exit}')

    # Extract hostnames
    host_line=$(echo "$output" | grep "Hostnames:")

    # Clean hostnames line
    hostnames=$(echo "$host_line" | sed 's/^.*Hostnames: //; s/;/ /g')

    if [ "$VERBOSE" == "true" ]; then
        echo "Hostnames: $hostnames"
    fi

    # Match hostnames against pattern
    if echo "$hostnames" | grep -Eq "$PATTERN"; then
        if [ "$VERBOSE" == "true" ]; then
            echo "IP Match: $ip"
        fi
        echo "$ip"
    fi
done | sort -u
