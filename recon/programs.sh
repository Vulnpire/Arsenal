### In-scope Assets

curl -sL https://raw.githubusercontent.com/projectdiscovery/public-bugbounty-programs/raw/master/chaos-bugbounty-list.json | jq -r '.[].targets.in_scope[] | [.target] | @tsv'

### BugCrowd Programs

#curl -s https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/bugcrowd_data.json | \
#jq -r '.[].targets.in_scope[] | select(.type == "website") | .target' | \
#awk '
#    /^https:\/\// { print $0 > "domains.txt" }
#    /^[^\/]*\*.+[.]com/ { print $0 > "wildcards.txt" }'

### BugCrowd Programs v2

curl -s 'https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/bugcrowd_data.json' | \
  jq -r '.[] | .targets.in_scope[] | select(.type == "website" or .type == "api") | .target' | \
  while read -r target; do
    if [[ "$target" == "https://"* ]]; then
      echo "$target" >> domains.txt
    elif [[ "$target" == "*."* ]]; then
      echo "$target" >> wildcards.txt
    fi
  done
  sed -i 's/^*\.//' wildcards.txt
# Fetch the IP ranges
curl -s 'https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/bugcrowd_data.json' | \
  jq -r '.[] | .targets.in_scope[] | select(.type == "network" or .type == "other" or .type == "api") | .target' | \
  while read -r target; do
    if [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ || "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
      echo "$target" >> ip_ranges.txt
    fi
  done

### Hackerone Programs

#curl -s https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/hackerone_data.json | jq -r '.[] | .targets.in_scope[] | select(.eligible_for_bounty == true and .asset_type == "URL") | .asset_identifier' > urls.txt && curl -s https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/hackerone_data.json | jq -r '.[] | .targets.out_of_scope[] | select(.asset_type == "WILDCARD") | .asset_identifier | sub("^\\*\\."; "")' > wildcards.txt

# V2
curl -s 'https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/hackerone_data.json' | \
  jq -r '.[] | .targets.in_scope[] | select(.eligible_for_submission == true and .eligible_for_bounty == false) | select(.asset_type == "URL" or .asset_type == "WILDCARD") | .asset_identifier' | \
  while read -r asset_identifier; do
    if [[ "$asset_identifier" == "http://"* || "$asset_identifier" == "https://"* ]]; then
      echo "$asset_identifier" >> urls.txt
    elif [[ "$asset_identifier" == "*."* ]]; then
      echo "$asset_identifier" >> wildcards.txt
    fi
  done
sed -i 's/^*\.//' wildcards.txt
sed -i 's/^https\?:\/\/\*\.//' urls.txt
grep -vE '^https?://' urls.txt >> wildcards.txt && sed -i '/^https\?:\/\//!d' urls.txt
# IP ranges
curl -s 'https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/hackerone_data.json' | \
  jq -r '.[] | select(.allows_bounty_splitting == true) | .targets.in_scope[] | select(.asset_type == "CIDR") | .asset_identifier' >> ip_ranges.txt

## ProjectDiscovery Inscope Targets

curl -s https://raw.githubusercontent.com/projectdiscovery/public-bugbounty-programs/main/chaos-bugbounty-list.json | \
jq -r '.programs[] | select(.bounty == true) | .domains[]' | \
awk '{
    if ($0 ~ /^https?:\/\//) {
        print $0 > "domains.txt"
    } else {
        print $0 > "wildcards.txt"
    }
}'

### Intigriti Programs

curl -s https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/intigriti_data.json | jq -r '.[].targets.in_scope[] | select(.impact != "Out of scope") | select(.type == "wildcard" or .type == "url") | .endpoint' | grep -e '^.*\..*\..*$' > wildcards.txt ; curl -s https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/intigriti_data.json | jq -r '.[].targets.in_scope[] | select(.impact != "Out of scope") | select(.type == "url") | .endpoint' > urls.txt
# Extract IP ranges
curl -s https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/intigriti_data.json | \
jq -r '.[].targets.in_scope[] | select(.impact != "Out of scope") | select(.type == "ip range") | .endpoint' > ip_ranges.txt

### YesWeHack Programs

curl -sL https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/main/data/yeswehack_data.json | jq -r '.[].targets.in_scope[] | [.target] | @tsv'

### HackenProof Programs

curl -sL https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/raw/master/data/hackenproof_data.json | jq -r '.[].targets.in_scope[] | [.target, .type, .instruction] | @tsv'

### Federacy Programs

curl -sL https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/raw/master/data/federacy_data.json | jq -r '.[].targets.in_scope[] | [.target] | @tsv'

## Scripting

## Removing unnecessary chars.
sed 's/^*\.//' wildcards.txt > modified_wildcards.txt && sed 's/\/\*$//' modified_wildcards.txt > final_wildcards.txt && cat final_wildcards.txt > wildcards.txt && rm -r modified_wildcards.txt final_wildcards.txt

sed 's/^*\.//g' wildcards.txt > tmp && cat tmp > wildcards.txt;rm tmp

# Params
sed 's/$/=/g' xss.urls > xss.params

## Will cut the half of .txt and paste it to another.
total_lines=$(wc -l < xss.params); half_lines=$((total_lines / 2)); { head -n "$half_lines" xss.params > xss.params.p2; sed -i "1,${half_lines}d" xss.params; }