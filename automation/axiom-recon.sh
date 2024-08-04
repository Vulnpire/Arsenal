#!/bin/bash

### Init
mkdir -p subdomains; mkdir -p crawl;mkdir -p tmp

### Subdomains
axiom-scan wildcards.txt -m subfinder -all -silent --rm-logs -anew sub.txt
axiom-scan wildcards.txt -m assetfinder -subs-only --rm-logs -anew sub.txt
shosubgo -f wildcards.txt -s $SHODAN_API_KEY | anew sub.txt && cat sub.txt | sort -u | anew subs.txt && mv subs.txt sub.txt

### Probing
axiom-scan sub.txt -m dnsx -o dnsx.txt --rm-logs
axiom-scan dnsx.txt -m naabu -anew ports.txt && rm dnsx.txt
axiom-scan ports.txt -m httpx -threads 300 -mc 200 -rl 250 -random-agent -title -td -probe -sc -ct -server -anew techs.txt --rm-logs && mv ports.txt tmp/

### Parsing
cat techs.txt | grep "200" | awk '{print $1}' > alive.txt
mv alive.txt techs.txt subdomains/

### Crawling
timeout --foreground 6700 axiom-scan wildcards.txt -m waymore -p 4 -mc 200 -mode U --rm-logs -anew waymore.txt
timeout --foreground 6700 axiom-scan wildcards.txt -m waybackurls --rm-logs -anew gau.txt
#paramspider -l wildcards.txt
#cat results/*.txt | uro | sed 's/FUZZ//g' > params.txt && rm -rf results/

## Add http
cat wildcards.txt | sed 's|^|http://|' > crawl.txt

timeout --foreground 5000 axiom-scan crawl.txt -m gospider -o out --rm-logs
find out/ -type f -exec cat {} + | sed -e 's/^\[linkfinder\] - //g' \
                                  -e 's/^\[url\] - \[code-[0-9]\{3\}\] - //g' \
                                  -e 's/^\[href\] - //g' \
                                  -e 's/^\[subdomains\] - //g' \
                                  -e 's/^\[javascript\] - //g' \
                                  -e 's/^\[form\] - //g' \
                                  -e 's/^[[:space:]]*//g' \
                                  -e 's/[[:space:]]*$//g' \
                                  -e '/^$/d' > cleaned_output.txt
rm -rf out/*

timeout --foreground 3700 axiom-scan crawl.txt -m hakrawler -anew hakrawler.txt --rm-logs
timeout --foreground 3700 axiom-scan crawl.txt -m katana -jsluice -kf all -pss waybackarchive,commoncrawl,alienvault -passive -jc -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.5790.171 Safari/537.36" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" -nc -d 10 -aff -c 30 -silent -s breadth-first -rl 150 -anew vkatana.txt --rm-logs
timeout --foreground 3700 axiom-scan crawl.txt -m katana -d 7 -display-out-scope --headless -jc -rl 100 -jsluice -aff --rm-logs -anew akatana.txt

cat waymore.txt gau.txt akatana.txt hakrawler.txt vkatana.txt cleaned_output.txt | sort -u | grep -Evi "png|jpg|gif|jpeg|swf|woff|svg|pdf|css|webp|woff|woff2|eot|ttf|otf|mp4|txt" | uro > uri.txt && rm crawl.txt waymore.txt gau.txt akatana.txt hakrawler.txt vkatana.txt cleaned_output.txt

mv uri.txt crawl/ #&& mv params.txt crawl/
