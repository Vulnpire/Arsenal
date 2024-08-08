#!/bin/bash

### Init
mkdir -p subdomains; mkdir -p crawl;mkdir -p ports

### Subdomains
axiom-scan wildcards.txt -m subfinder -all -silent --rm-logs -anew sub.txt
axiom-scan wildcards.txt -m assetfinder -subs-only --rm-logs -anew sub.txt
### Subdomains from google

# banshee -f wildcards.txt -s -p 5 -d 10 | anew sub.txt
shosubgo -f wildcards.txt -s $SHODAN_API_KEY | anew sub.txt && cat sub.txt | sort -u | anew subs.txt && mv subs.txt sub.txt

### Get IP addresses
# cat wildcards.txt | sXtract -ip > ips.txt
# cat wildcards.txt | uncover -silent | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | anew ips.txt

### Probing
axiom-scan sub.txt -m dnsx -o dnsx.txt --rm-logs
#axiom-scan dnsx.txt -m naabu -anew ports.txt && rm dnsx.txt # For passive scanning - cat dnsx.txt | spymap -c 100 -s $SHODAN_API_KEY | anew ports.txt
axiom-scan dnsx.txt -m httpx -threads 300 -rl 250 -random-agent -title -td -probe -sc -ct -server -ports 3000,5000,8080,8000,8081,8888,8009,8070,8071,8100,8083,8073,8099,8092,8074,8043,8035,7070,9001,7001,4443 -anew techs.txt --rm-logs # && mv ports.txt ports/

### Parsing
cat techs.txt | grep "200" | awk '{print $1}' > alive.txt
mv alive.txt techs.txt subdomains/ && rm sub.txt

### Crawling
timeout --foreground 6700 axiom-scan wildcards.txt -m waymore -p 4 -mc 200 -mode U --rm-logs -anew waymore.txt
timeout --foreground 6700 axiom-scan wildcards.txt -m waybackurls --rm-logs -anew gau.txt

cat waymore.txt | anew gau.txt && cat gau.txt | sort -u > temp && mv temp gau.txt && rm waymore.txt

#paramspider -l wildcards.txt
#cat results/*.txt | uro | sed 's/FUZZ//g' > params.txt && rm -rf results/

### Add http
cat wildcards.txt | sed 's|^|http://|' > crawl.txt

timeout --foreground 5000 axiom-scan crawl.txt -m gospider -o out --rm-logs
find out/ -type f -exec cat {} + | sed -e 's/^\[linkfinder\] - //g' \
                                  -e 's/^\[url\] - \[code-[0-9]\{3\}\] - //g' \
                                  -e 's/^\[href\] - //g' \
                                  -e 's/^\[subdomains\] - //g' \
                                  -e 's/^\[javascript\] - //g' \
                                  -e 's/^\[form\] - //g' \
                                  -e 's/^[[:space:]]*//g' \
                                  -e 's/^\[upload-form\] - //g' \
                                  -e 's/^\[aws-s3\] - //g' \
                                  -e 's/[[:space:]]*$//g' \
                                  -e '/^$/d' | sort -u > cleaned_output.txt
rm -rf out/

## Hakrawler
timeout --foreground 3700 axiom-scan crawl.txt -m hakrawler -anew hakrawler.txt --rm-logs
cat cleaned_output.txt | anew hakrawler.txt && rm cleaned_output.txt

## Katana - Passive
timeout --foreground 3700 axiom-scan crawl.txt -m katana -jsluice -kf all -pss waybackarchive,commoncrawl,alienvault -passive -jc -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.5790.171 Safari/537.36" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" -nc -d 10 -aff -c 30 -silent -s breadth-first -rl 190 -anew vkatana.txt --rm-logs
cat vkatana.txt | anew hakrawler.txt && rm vkatana.txt

## Katana - Active Remove headers if you'd like to use -headless
timeout --foreground 3700 axiom-scan crawl.txt -m katana -H "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 OPR/110.0.0.0 (Edition Yx 05)" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" -jc -rl 180 -s breadth-first -jsluice -kf all -aff --rm-logs -anew akatana.txt
cat akatana.txt | anew hakrawler.txt && cat hakrawler.txt | sort -u > temp && mv temp hakrawler.txt
cat gau.txt hakrawler.txt | sort -u | grep -Evi "png|jpg|gif|jpeg|swf|woff|svg|pdf|css|webp|woff|woff2|eot|ttf|otf|mp4|txt" | uro > uri.txt && rm crawl.txt gau.txt hakrawler.txt akatana.txt

mv uri.txt crawl/ && mv params.txt crawl/
