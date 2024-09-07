# Arsenal

## Get All IPs from Shodan

```cat domains.txt | sXtract -ip``` [link](https://github.com/Vulnpire/shodanXtract).

OR

```curl -s "https://www.shodan.io/search/facet?query=ssl.cert.subject.cn%3A%22target.com%22&facet=ip" | grep -oP '(?<=<strong>)[^<]+(?=</strong>)' | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | anew ips.txt```

OR

```var ipElements=document.querySelectorAll('strong');var ips=[];ipElements.forEach(function(e){ips.push(e.innerHTML.replace(/["']/g,''))});var ipsString=ips.join('\n');var a=document.createElement('a');a.href='data:text/plain;charset=utf-8,'+encodeURIComponent(ipsString);a.download='ips.txt';document.body.appendChild(a);a.click();```

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

## Sensitive Files and Directories

`cat uri.txt | uro | sort -u | grep -Ei 'admin|dashboard|panel|phpmyadmin|wp-admin|confluence|secureadmin|sitemanager|drupal|config|myadmin|sqladmin|grafana|kibana|metrics|backup|api|zabbix|prometheus|splunk|database|phppgadmin|ghost|joomla'`

## Common backup, logs, and configuration files, vulnerable endpoints

`cat uri.txt | uro | sort -u | sort -u | grep -Ei '(\.git|\.svn|\.backup|\.env|\.bak|\.old|\.log|\.conf|\.config|\.ini|\.sql|\.dump|xmlrpc\.php|_fragment|env\.js|\.gitlab-ci\.yml|\.cgf|\.xml|\.xls|\.xlsx|\.json|\.war|\.ear|\.sqlitedb|\.sqlite3|\.properties|\.pem|\.key|tar\.gz|.\py|\.sh)$'`

## Common patterns for file inclusion and directory traversal

`cat uri.txt | uro | sort -u | grep -Ei '\?(file|page|path|doc|folder|dir|inc|locate|conf)='`

## Common parameters for session management

`cat uri.txt | uro | sort -u | grep -Ei '\?(token|auth|session|sid|csrf|xsrf)='`

## Common parameters used in command injection

`cat uri.txt | sort -u | grep -Ei '\?(cmd|exec|command|run|execute|shell)='`

## Regex for API Enumeration

`cat uri.txt | sort -u | grep -Ei '/api/v[1-3]/[a-z]+/[0-9]+|/api/[0-9]+/[a-z]+/[0-9]+|/v[0-9]+/[a-z]+/[0-9]+|/rest(/v[0-9]+)?/|/graphql|/swagger|/auth|/internal/create/get/post|'`

## IDOR Prone Endpoints & Params

`cat uri.txt | sort -u | grep -Ei '\?invoice=|changepassword\?user=|showImage|accessPage\?menuitem=|user_id=|MyPictureList=|profile_id=|account_id=|order_id=|page_id=|product_id=|session_id=|invoice_id=|doc_id='`

## Regex for XXE

`cat uri.txt | sort -u | grep -Ei "(xml|data|content|file|input|entity|config|document|payload|request)="`

## Regex for SSTI

`cat uri.txt | sort -u | grep -Ei "(template|name|message|user|description|email|subject|content|query|title)="`

## Fast Nmap Scan

`ports=$(nmap -p- --min-rate=1000 -T4 -Pn $IP | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//) && nmap -p$ports -sC -sV -D RND:13.37.73.31 -Pn $IP --min-rate=500 -T4`
