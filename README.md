# Arsenal

## Get All IPs from Shodan

```cat domains.txt | sXtract -ip``` [link](https://github.com/Vulnpire/shodanXtract).

## Uncover

```uncover -silent -s 'ssl.cert.subject.CN:"target.com" -http.title:"Invalid URL" -http.title:"ERROR: The request could not be satisfied"' | sort -u```

## Uncover 2

```uncover -q 'target.com' -e "shodan, shodanIb, hunterio, criminalip, Zoomeye, Censys, netlas, fullhunt, hunterhow, publicwww" -silent```

## Uncover Wildcards

```for i in `cat wildcards.txt`; do uncover -l 6000 -silent -s "ssl.cert.subject.CN:\"$i\"" | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u | anew ips.txt; done```

## ASNs Google Dork

```site:ipinfo.io "Steam"```
