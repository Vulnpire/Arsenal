#!/bin/bash

REPO_FILE="repos.txt"

SLEEP_TIME=$((45 * 60))

scan_repos() {
    while IFS= read -r repo_url; do
        if [[ -n "$repo_url" ]]; then
            echo "Scanning repository: $repo_url"
            trufflehog git "$repo_url" --only-verified | anew gits.txt
#            for file in tmp/gits.*.txt; do diff "$file" gits.txt | grep -o '>.*' | sed 's/^> //' ; done | sort -u > clean.txt
            cat gits.txt | notify -id gitleaks -bulk
            mv gits.txt tmp/gits.$(date +%s).txt #&& rm clean.txt
        fi
    done < "$REPO_FILE"
}

while true; do
    scan_repos
    echo "Sleeping for 45 minutes..." | notify -id gitleaks
    sleep $SLEEP_TIME
done
