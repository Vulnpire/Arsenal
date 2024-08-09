#!/bin/bash

mkdir -p subdomains crawl ports checks/{sqli,xss,redirect,sensitive,exposure,lfi,mgmt,rce,api}

FILE="wildcards.txt"

while getopts "f:" opt; do
  case $opt in
    f)
      FILE="$OPTARG"
      ;;
    *)
      echo "Usage: $0 [-f file]"
      exit 1
      ;;
  esac
done

run_subdomain_enumeration() {
    axiom-scan "$FILE" -m subfinder -all -silent --rm-logs -anew sub.txt
    axiom-scan "$FILE" -m assetfinder -subs-only --rm-logs -anew sub.txt
    shosubgo -f "$FILE" -s "$SHODAN_API_KEY" | anew sub.txt
    cat sub.txt | sort -u > temp && mv temp sub.txt
}

run_probing() {
    axiom-scan sub.txt -m dnsx -o dnsx.txt --rm-logs
    # axiom-scan dnsx.txt -m naabu -anew ports.txt && rm dnsx.txt
    axiom-scan dnsx.txt -m httpx -threads 300 -rl 250 -random-agent -title -td -probe -sc -ct -server -dashboard -ports 3000,5000,8080,8000,8081,8888,8069,8009,8070,8088,8050,8085,8089,8040,8020,8051,8087,8071,8011,8030,8061,8072,8100,8083,8073,8099,8092,8074,8043,8035,7070,9001,7001,4443 -anew techs.txt --rm-logs
    mv ports.txt ports/
    awk '{print $1}' techs.txt > subdomains/alive.txt && mv techs.txt subdomains/
    rm sub.txt
}

run_crawling() {
    timeout --foreground 6700 axiom-scan "$FILE" -m waymore -p 4 -mc 200 -mode U --rm-logs -anew waymore.txt
    timeout --foreground 6700 axiom-scan "$FILE" -m waybackurls --rm-logs -anew gau.txt
    grep -Evi "png|jpg|gif|jpeg|swf|woff|svg|pdf|css|webp|woff|woff2|eot|ttf|otf|mp4|txt" gau.txt | sort -u > gau_cleaned.txt
    cat waymore.txt | anew gau_cleaned.txt && sort -u gau_cleaned.txt > gau.txt && rm waymore.txt gau_cleaned.txt
    sed 's|^|http://|' "$FILE" > crawl.txt

    run_advanced_crawling
}

run_advanced_crawling() {
    timeout --foreground 5000 axiom-scan crawl.txt -m gospider -o out --rm-logs
    find out/ -type f -exec cat {} + | sed -e 's/^\[linkfinder\] - //g' \
                                      -e 's/^\[url\] - \[code-[0-9]\{3\}\] - //g' \
                                      -e 's/^\[href\] - //g' \
                                      -e 's/^\[subdomains\] - //g' \
                                      -e 's/^\[javascript\] - //g' \
                                      -e 's/^\[form\] - //g' \
                                      -e 's/^\[upload-form\] - //g' \
                                      -e 's/^\[aws-s3\] - //g' \
                                      -e 's/[[:space:]]*$//g' \
                                      -e '/^$/d' | sort -u > cleaned_output.txt
    rm -rf out/

    run_hakrawler
}

run_hakrawler() {
    timeout --foreground 3700 axiom-scan crawl.txt -m hakrawler -anew hakrawler.txt --rm-logs
    cat cleaned_output.txt | anew hakrawler.txt && rm cleaned_output.txt

    run_katana
}

run_katana() {
    local headers='-H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.5790.171 Safari/537.36"'
    local active_headers='-H "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 OPR/110.0.0.0 (Edition Yx 05)"'

    timeout --foreground 3700 axiom-scan crawl.txt -m katana -jsluice -kf all -pss waybackarchive,commoncrawl,alienvault -passive -jc $headers -nc -d 10 -aff -c 30 -silent -s breadth-first -rl 190 -anew vkatana.txt --rm-logs
    cat vkatana.txt | anew hakrawler.txt && rm vkatana.txt

    timeout --foreground 3700 axiom-scan crawl.txt -m katana $active_headers -jc -rl 180 -s breadth-first -jsluice -kf all -aff --rm-logs -anew akatana.txt
    cat akatana.txt | anew hakrawler.txt && cat hakrawler.txt | sort -u > temp && mv temp hakrawler.txt
    cat gau.txt hakrawler.txt | sort -u | uro > uri.txt
    rm crawl.txt gau.txt hakrawler.txt akatana.txt
    mv uri.txt crawl/
}

run_checks() {
    local uri_file="crawl/uri.txt"

    declare -A checks
    checks=(
        ["sqli"]='\?(id|param|cat|cat_id)='
        ["xss"]='\?(name|query|search|keyword|username|email|message|comment|body|input|value|arg|data|q)='
        ["redirect"]='\?(url|uri|path|dest|destination|redir|redirect_uri|redirect_url|redirect|forward|callback|continue|link|next|return|goto|rurl|target|out|view|ref|feed|data|port|domain|load|site|source|window|dir|show|navigation|open|file|val|validate|loginto|image_url|go|returnTo|return_to|checkout_url|reference|page|host)='
        ["sensitive"]='admin|dashboard|panel|phpmyadmin|wp-admin|confluence|secureadmin|sitemanager|drupal|config|myadmin|sqladmin|grafana|kibana|metrics|backup|api|zabbix|prometheus|splunk|database|phppgadmin|ghost|joomla'
        ["exposure"]='\.(git|env|bak|old|log|conf|config|ini|sql|dump|xmlrpc\.php|_fragment|env\.js|gitlab-ci\.yml)'
        ["lfi"]='\?(file|page|path|doc|folder|dir)='
        ["mgmt"]='\?(token|auth|session|sid|csrf|xsrf)='
        ["rce"]='\?(cmd|exec|command|run|execute|shell)='
        ["api"]='/api/v[1-3]/[a-z]+/[0-9]+'
    )

    for check in "${!checks[@]}"; do
        grep -Ei "${checks[$check]}" "$uri_file" | uro | sort -u > "checks/$check/$check.txt"
    done
}

if [[ "$1" == "-ip" ]]; then
    cat "$FILE" | sXtract -ip > ips.txt
    cat "$FILE" | uncover -silent | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | anew ips.txt
elif [[ "$1" == "-deep" ]]; then
    run_subdomain_enumeration
    run_probing
    run_crawling
    run_checks
fi
