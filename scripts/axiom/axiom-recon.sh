#!/bin/bash

mkdir -p subdomains crawl ports checks/{sqli,xss,redirect,sensitive,exposure,lfi,mgmt,rce,api,ips}

FILE="wildcards.txt"

# Initialize flags
SUBS=false
MASS_DNS=false
IP=false
CRAWL=false
WAYMORE=false
CHECK=false
ALL=false
DOMAIN=false

# Parse the arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -f)
            FILE="$2"
            shift 2
            ;;
        -subs)
            SUBS=true
            shift
            ;;
        -mass-dns)
            MASS_DNS=true
            shift
            ;;
        -ip)
            IP=true
            shift
            ;;
        -crawl)
            CRAWL=true
            shift
            ;;
        -waymore)
            WAYMORE=true
            shift
            ;;
        -check)
            CHECK=true
            shift
            ;;
        -domain)
            DOMAIN=true
            shift
            ;;
        -all)
            ALL=true
            shift
            ;;
        *)
            echo "Usage: $0 [-f file] [-subs] [-ip] [-crawl] [-waymore] [-check] [-all] [-mass-dns] [-domain]"
            exit 1
            ;;
    esac
done

run_subdomain_enumeration() {
    axiom-scan "$FILE" -m subfinder -all -silent -recursive --rm-logs -anew sub.txt
    axiom-scan "$FILE" -m assetfinder -subs-only --rm-logs -anew sub.txt
    shosubgo -f "$FILE" -s "$SHODAN_API_KEY" | anew sub.txt
    axiom-scan "$FILE" -m findomain --external-subdomains -r -anew temp --rm-logs && cat temp | anew sub.txt
    cat sub.txt | sort -u > temp && mv temp sub.txt
    run_probing
}

run_dns_mass() {
    axiom-scan "$FILE" -m subfinder -all -silent -recursive --rm-logs -anew sub.txt
    axiom-scan sub.txt -m subfinder -all -silent -recursive --rm-logs -anew temp && cat temp | anew sub.txt && rm temp
    axiom-scan "$FILE" -m assetfinder -subs-only --rm-logs -anew sub.txt
    shosubgo -f "$FILE" -s "$SHODAN_API_KEY" | anew sub.txt
    axiom-scan "$FILE" -m findomain --external-subdomains -r -anew temp && mv temp sub.txt
    cat sub.txt | sort -u > temp && mv temp sub.txt
    run_probing
}

run_probing() {
    axiom-exec "curl -s https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt > /home/op/lists/resolvers.txt"
    axiom-scan sub.txt -m dnsx -threads 300 -o dnsx.txt --rm-logs
    axiom-scan dnsx.txt -m httpx -threads 300 -rl 250 -random-agent -title -td -probe -sc -ct -server -anew techs.txt --rm-logs
    mv techs.txt subdomains/
    rm sub.txt
}

run_sub_portscan() {
    cat subdomains/alive.txt | anew ips.check
    axiom-scan ips.check -m dnsx -threads 300 -o sub.ips.dnsx --rm-logs
    cat sub.ips.dnsx | sed -e 's/^http:\/\/\(.*\)/\1/' -e 's/^https:\/\/\(.*\)/\1/' > temp && mv temp sub.ips.dnsx && rm ips.check
    for i in $(cat sub.ips.dnsx);do shodan host $i;done | anew check/ips/sub.ports
    axiom-scan sub.ips.dnsx -m httpx -threads 300 -rl 200 -anew sub.ips.httpx --rm-logs
    rm sub.ips.dnsx && mv sub.ips.httpx checks/ips/
}

run_waymore() {
    timeout --foreground 6700 axiom-scan "$FILE" -m waymore -p 5 -mc 200 -mode U --rm-logs -anew gau.txt
    run_crawling
}

run_crawling() {
    timeout --foreground 6700 axiom-scan "$FILE" -m waybackurls --rm-logs -anew gau.txt
    cat "$FILE" | gau --threads 25 --subs --providers wayback,commoncrawl,otx,urlscan --mc 200 --blacklist png,jpg,jpeg,gif,mp3,mp4,svg,woff,woff2,otf,css,exe,ttf,eot | anew gau.txt
    grep -Evi "png|jpg|gif|jpeg|swf|woff|svg|pdf|css|webp|woff|woff2|eot|ttf|otf|mp4|txt" gau.txt | sort -u > temp && mv temp gau.txt
    sed 's|^|http://|' "$FILE" > crawl.txt

    run_advanced_crawling
}

run_advanced_crawling() {
    timeout --foreground 5000 axiom-scan crawl.txt -m gospider --subs --include-subs -o out --rm-logs
    find out/ -type f -exec cat {} + | sed -e 's/^\[linkfinder\] - //g' \
                                      -e 's/^\[url\] - \[code-[0-9]\{3\}\] - //g' \
                                      -e 's/^\[href\] - //g' \
                                      -e 's/^\[subdomains\] - //g' \
                                      -e 's/^\[javascript\] - //g' \
                                      -e 's/^\[form\] - //g' \
                                      -e 's/^\[upload-form\] - //g' \
                                      -e 's/^\[aws-s3\] - //g' \
                                      -e 's/[[:space:]]*$//g' \
                                      -e '/^$/d' | grep -Evi "png|jpg|gif|jpeg|swf|woff|svg|pdf|css|webp|woff|woff2|eot|ttf|otf|mp4|txt" | sort -u > cleaned_output.txt
    rm -rf out/

    run_hakrawler
}

run_hakrawler() {
    timeout --foreground 3700 axiom-scan crawl.txt -m hakrawler -subs -anew hakrawler.txt --rm-logs
    cat cleaned_output.txt | anew hakrawler.txt && rm cleaned_output.txt

    run_advanced_crawling2
}

run_advanced_crawling2() {
    timeout --foreground 4800 axiom-scan hakrawler.txt -m hakrawler -subs -o plus --rm-logs

    cat plus | anew hakrawler.txt && rm plus
    run_katana
}

run_katana() {
    local headers='-H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.5790.171 Safari/537.36"'
 
    timeout --foreground 3700 axiom-scan crawl.txt -m katana -jsluice -kf all -pss waybackarchive,commoncrawl,alienvault -passive -jc $headers -nc -d 10 -aff -c 30 -silent -s breadth-first -rl 190 -anew vkatana.txt --rm-logs
    cat vkatana.txt | anew hakrawler.txt && rm vkatana.txt

    timeout --foreground 3200 axiom-scan hakrawler.txt -m hakrawler -subs -o plus --rm-logs && cat plus | anew hakrawler.txt && rm plus
    cat hakrawler.txt | sort -u > temp && mv temp hakrawler.txt
    cat gau.txt hakrawler.txt | sort -u | uro > uri.txt
    rm crawl.txt gau.txt hakrawler.txt
    mv uri.txt crawl/

    timeout --foreground 3300 axiom-scan crawl/uri.txt -m gospider --subs --include-subs -o plus --rm-logs

    find plus/ -type f -exec cat {} + | sed -e 's/^\[linkfinder\] - //g' \
                                      -e 's/^\[url\] - \[code-[0-9]\{3\}\] - //g' \
                                      -e 's/^\[href\] - //g' \
                                      -e 's/^\[subdomains\] - //g' \
                                      -e 's/^\[javascript\] - //g' \
                                      -e 's/^\[form\] - //g' \
                                      -e 's/^\[upload-form\] - //g' \
                                      -e 's/^\[aws-s3\] - //g' \
                                      -e 's/[[:space:]]*$//g' \
                                      -e '/^$/d' | grep -Evi "png|jpg|gif|jpeg|swf|woff|svg|pdf|css|webp|woff|woff2|eot|ttf|otf|mp4|txt" | sort -u > cleaned_output.txt
    rm -rf plus/
    cat cleaned_output.txt | anew crawl/uri.txt && rm cleaned_output.txt
    grep -E "$(paste -sd '|' wildcards.txt)" crawl/uri.txt > temp && mv temp crawl/uri.txt
    cat crawl/uri.txt | grep -Ei "\.js$" > crawl/js.urls
}

run_only_domain() {
    timeout --foreground 6700 axiom-scan "$FILE" -m waymore -n -p 4 -mc 200 -mode U --rm-logs -anew gau.txt
    cat "$FILE" | gau --threads 16 --providers wayback,commoncrawl,otx,urlscan --blacklist png,jpg,jpeg,gif,mp3,mp4,svg,woff,woff2,otf,css,exe,ttf,eot | anew gau.txt
    grep -Evi "png|jpg|gif|jpeg|swf|woff|svg|pdf|css|webp|woff|woff2|eot|ttf|otf|mp4|txt" gau.txt | sort -u > temp && mv temp gau.txt
    sed 's|^|http://|' "$FILE" > crawl.txt

    timeout --foreground 5000 axiom-scan crawl.txt -m gospider -o out --rm-logs
    find plus/ -type f -exec cat {} + | sed -e 's/^\[linkfinder\] - //g' \
                                      -e 's/^\[url\] - \[code-[0-9]\{3\}\] - //g' \
                                      -e 's/^\[href\] - //g' \
                                      -e 's/^\[subdomains\] - //g' \
                                      -e 's/^\[javascript\] - //g' \
                                      -e 's/^\[form\] - //g' \
                                      -e 's/^\[upload-form\] - //g' \
                                      -e 's/^\[aws-s3\] - //g' \
                                      -e 's/[[:space:]]*$//g' \
                                      -e '/^$/d' | grep -Evi "png|jpg|gif|jpeg|swf|woff|svg|pdf|css|webp|woff|woff2|eot|ttf|otf|mp4|txt" | sort -u > cleaned_output.txt
    rm -rf out/

    timeout --foreground 3700 axiom-scan crawl.txt -m hakrawler -anew hakrawler.txt --rm-logs
    cat cleaned_output.txt | anew hakrawler.txt && rm cleaned_output.txt

    timeout --foreground 4800 axiom-scan hakrawler.txt -m hakrawler -o plus --rm-logs

    cat plus | anew hakrawler.txt && rm plus

    local dom_headers='-H "User-Agent: Mozilla/5.0 (Linux; Android 11; DT2002C; Build/RKQ1.201217.002) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.4280.141 Mobile Safari/537.36 Firefox-KiToBrowser/124.0"'
    
    timeout --foreground 3700 axiom-scan crawl.txt -m katana -jsluice -kf all -fs dn -pss waybackarchive,commoncrawl,alienvault -passive -jc $dom_headers -nc -d 10 -aff -c 30 -silent -s breadth-first -rl 190 -anew vkatana.txt --rm-logs
    cat vkatana.txt | anew hakrawler.txt && rm vkatana.txt

    timeout --foreground 3200 axiom-scan hakrawler.txt -m hakrawler -o plus --rm-logs && cat plus | anew akatana.txt && rm plus
    cat akatana.txt | anew hakrawler.txt && cat hakrawler.txt | sort -u > temp && mv temp hakrawler.txt
    cat gau.txt hakrawler.txt | sort -u | uro > uri.txt
    rm crawl.txt gau.txt hakrawler.txt akatana.txt
    grep -E "$(paste -sd '|' wildcards.txt)" uri.txt > temp && mv temp uri.txt
    mv uri.txt crawl/
    cat crawl/uri.txt | grep -Ei "\.js$" > crawl/js.urls

    run_checks
}

run_checks() {
    local uri_file="crawl/uri.txt"

    declare -A checks
    checks=(
        ["sqli"]='\?(id|param|cat|cat_id)='
        ["xss"]='\?(name|query|search|keyword|username|email|message|comment|body|input|value|arg|data|q)='
        ["redirect"]='\?(url|uri|path|dest|destination|redir|redirect_uri|redirect_url|redirect|forward|callback|continue|link|next|return|goto|rurl|target|out|view|ref|feed|data|port|domain|load|site|source|window|dir|show|navigation|open|file|val|validate|loginto|image_url|go|returnTo|return_to|checkout_url|reference|page|host)='
        ["sensitive"]='admin|dashboard|panel|phpmyadmin|wp-admin|confluence|secureadmin|sitemanager|drupal|config|myadmin|sqladmin|grafana|kibana|metrics|backup|api|zabbix|prometheus|splunk|database|phppgadmin|ghost|joomla'
        ["exposure"]='\.(git|env|bak|old|log|conf|config|ini|sql|dump|xmlrpc\.php|_backup|\.backup|svn|cvs|swp|tar|tgz|zip|old|backup|bz2|rar|gz|7z|lst|md|lst|pmd|~|backup|crt|key|json|secret|cache)'
        ["lfi"]='\?(page|file|document|folder|root|path|pg)='
        ["mgmt"]='cgi-bin|phpmyadmin|admin|manager|console|support|webmail|shell|cmd|run|exec|system|zimbra|desktop|wp-admin|admin_login|php|www|_admin'
        ["rce"]='cmd|exec|system|run|eval|load|popen|proc_open|shell_exec|passthru|curl_exec|shell_exec|passthru|proc_open|assert|require|require_once|create_function|include|include_once|dl|readfile|popen|passthru'
        ["api"]='/api/v1/[a-z]+/[0-9]+|/api/v2/[a-z]+/[0-9]+|/api/v3/[a-z]+/[0-9]+|/rest'
    )

    for check in "${!checks[@]}"; do
        grep -Ei "${checks[$check]}" "$uri_file" > "checks/$check/check.txt"
    done

    rm $uri_file
}

if $ALL; then
    run_subdomain_enumeration
    run_waymore
    run_checks
elif $SUBS; then
    run_subdomain_enumeration
elif $MASS_DNS; then
    run_dns_mass
elif $IP; then
    run_sub_portscan
elif $CRAWL; then
    run_crawling
elif $WAYMORE; then
    run_waymore
elif $CHECK; then
    run_checks
elif $DOMAIN; then
    run_only_domain
else
    echo "Usage: $0 [-f file] [-subs] [-ip] [-crawl] [-waymore] [-check] [-all] [-domain]"
    exit 1
    
fi

rm -rf sub.txt
