# Arsenal

## Get All IPs from Shodan

```cat domains.txt | sXtract -ip``` or ```curl -s "https://www.shodan.io/search/facet?query=ssl.cert.subject.cn%3A%22target.com%22&facet=ip" | grep -oP '(?<=<strong>)[^<]+(?=</strong>)' | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}```

## Uncover

```uncover -silent -s 'ssl.cert.subject.CN:"target.com" -http.title:"Invalid URL" -http.title:"ERROR: The request could not be satisfied"' | sort -u```

## Uncover 2

```uncover -q 'target.com' -e "shodan, shodanIb, hunterio, criminalip, Zoomeye, Censys, netlas, fullhunt, hunterhow, publicwww" -silent```

## Uncover Wildcards

```for i in `cat wildcards.txt`; do uncover -l 6000 -silent -s "ssl.cert.subject.CN:\"$i\"" | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u | anew ips.txt; done```

## ASNs Google Dork

```site:ipinfo.io "Steam"```
