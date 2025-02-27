#!/bin/bash

axiom-scan check.txt -m sXtract -ip -q "200 OK" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.component:'WordPress'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q '"Apache Tomcat" "Manager App"' -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.component:'jenkins'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.html:'admin login'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.html:'/cgi-bin/'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.html:'development environment'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.html:'Jenkins'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.html:'MongoDB'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.html:'panel'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.html:'phpinfo'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.html:'Powered by WordPress'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'admin'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'Dashboard'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'Dashboard [Jenkins]'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'influxdb'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'Joomla!'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'kibana'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'minio'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'phpmyadmin'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'staging'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'test'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'web management interface'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.title:'zabbix'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "influxdb" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "kibana" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "port:(27017 OR 5984 OR 11211 OR 6379 OR 9200 OR 5555 OR 1000 OR 3389 OR 3306 OR 5432 OR 5555 OR 6666 OR 4443 OR 8443 OR 3000 OR 5000 OR 7000 OR 8000 OR 8080 OR 8443 OR 9000 OR 10000 OR 10001)" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "product:'Elasticsearch'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "product:'MySQL'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "product:'Redis'" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "sonarqube" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "wp-content" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "wp-login.php" -anew ips.txt
axiom-scan check.txt -m sXtract -ip -q "http.html:'/wp-content/plugins/'" -anew ips.txt
