axiom-scan check.txt -m sXtract -ip -q \"200 OK\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.component:\"WordPress\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"\"Apache Tomcat\" \"Manager App\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.component:\"jenkins\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.html:\"admin login\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.html:\"/cgi-bin/\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.html:\"development environment\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.html:\"Jenkins\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.html:\"MongoDB\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.html:\"panel\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.html:\"phpinfo\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.html:\"Powered by WordPress\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"admin\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"Dashboard\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"influxdb\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"Joomla!\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"kibana\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"minio\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"phpmyadmin\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"staging\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"test\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"web management interface\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.title:\"zabbix\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"port:(27017 OR 5984 OR 11211 OR 6379 OR 9200 OR 5555 OR 1000 OR 3389 OR 3306 OR 5432 OR 5555 OR 6666 OR 4443 OR 8443 OR 3000 OR 5000 OR 7000 OR 8000 OR 8080 OR 8443 OR 9000 OR 10000 OR 10001)\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"product:\"Elasticsearch\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"product:\"MySQL\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"product:\"Redis\"\" -anew tmp/ips.$(date +%s).txt
axiom-scan check.txt -m sXtract -ip -q \"http.html:\"/wp-content/plugins/\"\" -anew tmp/ips.$(date +%s).txt
