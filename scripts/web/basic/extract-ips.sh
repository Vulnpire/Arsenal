#!/bin/bash

# Ensure input is provided
if [ $# -lt 1 ]; then
    echo "Usage: echo <domain_or_file> | ./extract-ips.sh <domain_or_file> [-v]"
    exit 1
fi

INPUT="$1"
VERBOSE=""

# Check for -v flag for verbose output
if [ "$2" == "-v" ]; then
    VERBOSE="true"
fi

# Check if INPUT is a file or a single domain
if [ -f "$INPUT" ]; then
    PATTERN=$(tr '\n' '|' < "$INPUT" | sed 's/|$//')
else
    PATTERN="$INPUT"
fi

# Debugging: Check if pattern is being passed correctly
if [ "$VERBOSE" == "true" ]; then
    echo "Using pattern: $PATTERN"
fi

# Process input from stdin and handle it line by line
xargs -n 1 -I {} bash -c '
    sleep 3  # Add delay before each request
    shodan host {}' | awk -v pattern="$PATTERN" -v verbose="$VERBOSE" '
    # Match IP address (only the first occurrence)
    /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {
        ip=$1
    }

    # Capture the "Hostnames" line, which contains domain names
    /Hostnames:/ {
        # Extract the hostnames part after the colon and trim spaces
        hostnames = substr($0, index($0, "Hostnames:") + 10)
        # Replace semicolons with spaces to facilitate pattern matching
        gsub(";", " ", hostnames)
        # Debugging: Print the hostnames for verification
        if (verbose == "true") {
            print "Hostnames: " hostnames
        }
        # Check if any of the hostnames match the given pattern
        if (hostnames ~ pattern) {
            if (verbose == "true") {
                print "IP Match: " ip
            }
            print ip
        }
    }
' | sort -u  # Sort the IPs and remove duplicates
