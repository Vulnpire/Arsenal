## Clusterbomb Mode
Tests all combinations from multiple wordlists.

`ffuf -w users.txt:USER -w passwords.txt:PASS -u https://example.com/login?username=USER&password=PASS --mode clusterbomb`

## Pitchfork Mode
Matches items from wordlists in a one-to-one pairing.

`ffuf -w users.txt:USER -w passwords.txt:PASS -u https://example.com/login?username=USER&password=PASS --mode pitchfork`

## Sniper Mode
Fuzzes one parameter at a time, keeping others constant.

`ffuf -w payloads.txt -u https://example.com/search?query=FUZZ&staticparam=value --mode sniper`

# Matchers

## Status Code Matcher

Matches specific status codes.

`ffuf -u https://example.com/FUZZ -w wordlist.txt -mc 200`

## Response Size Matcher

Matches based on content length.

`ffuf -u https://example.com/FUZZ -w wordlist.txt -ms 900-1100`

## Word Count Matcher

Matches by word count in the response.

`ffuf -u https://example.com/FUZZ -w wordlist.txt -mw 50`

## Line Count Matcher

Matches responses by the number of lines.

`ffuf -u https://example.com/FUZZ -w wordlist.txt -ml 10`

## Regex Matcher

Filters responses containing specific patterns.

`ffuf -u https://example.com/FUZZ -w wordlist.txt -mr 'success|welcome'`

# Throttling & Delays

## Rate Limiting

Controls request rate and response timeout.

`ffuf -w /path/to/wordlist.txt -u https://example.com/FUZZ -rate 50 -timeout 5`

## Request Delays

Introduces delay between requests to avoid blocking.

`ffuf -w wordlist.txt -u https://example.com/FUZZ -t 2 -p 1`

# Fuzzing POST Requests

## Simple POST Fuzzing

Fuzzes form inputs via POST method.

`ffuf -w usernames.txt -u https://example.com/login -X POST -d "username=FUZZ&password=admin"`

## Fuzzing JSON POST Data

Fuzzes JSON-based API payloads.

`ffuf -X POST -H "Content-Type: application/json" -d '{"username": "admin", "password": "FUZZ"}' -w /path/to/wordlist.txt -u http://example.com/api/login`

# Headers & Output Options

## Custom Header Fuzzing

Fuzzes authorization tokens or headers.

`ffuf -w tokens.txt -H "Authorization: Bearer FUZZ" -u https://example.com/api/resource`

## Output in Various Formats

Saves results in JSON, CSV, or all formats.

`ffuf -w /path/to/wordlist.txt -u https://example.com/FUZZ -o results.json -of json`

# Combination with Nmap

## Fuzzing Discovered Services

After scanning with nmap, use ffuf to fuzz discovered services.

`nmap -p- -oG open_ports.txt 192.168.1.1`
`ffuf -w open_ports.txt -u http://192.168.1.1:FUZZ -o results.html`

# Recursive Directory Fuzzing with Custom Headers and Filters

## Advanced Directory Fuzzing with Recursion

This command performs directory fuzzing with recursion, excludes certain status codes, and adds custom headers. It also fuzzes with multiple file extensions.

`ffuf -w dirs.txt:FUZZ -u https://example.com/FUZZ -fc 400,401,402,403,404,429,500,501,502,503 -recursion -recursion-depth 2 -e .html,.php,.txt,.pdf,.js,.css,.zip,.bak,.old,.log,.json,.xml,.config,.env,.asp,.aspx,.jsp,.gz,.tar,.sql,.db -ac -c -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 11_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/33.0 Mobile/15E148 Safari/605.1.15" -H "X-Forwarded-For: 127.0.0.1" -H "X-Originating-IP: 127.0.0.1" -H "X-Forwarded-Host: localhost" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" -t 100 -r`

# Directory and File Fuzzing

## Fuzzing Directories and Files

Fuzzes both directory and file names to increase chances of finding hidden resources within nested paths.

`ffuf -w dirs.txt:DIR -w files.txt:FILE -u https://example.com/DIR/FILE`

## Fuzzing API Endpoints with Specific Status Code Filters

Fuzzes API endpoints and filters out common error codes while setting custom headers and high concurrency.

`ffuf -w /path/to/api-wordlist.txt -u https://example.com/api/FUZZ -fc 403,404,500 -H "Authorization: Bearer mytoken" -H "X-Real-IP: 127.0.0.1" -t 100 -ac -c`

## Fuzzing Subdomains with Recursion and Extensions

This command recursively fuzzes subdomains and applies extensions.

`ffuf -w /path/to/subdomains.txt -u https://FUZZ.example.com -recursion -recursion-depth 2 -e .com,.org,.net,.io -fc 400,401,403,500 -t 50 -ac -c`

## Fuzzing Parameters in a POST Request with JSON Payload

Fuzzes a JSON payload by replacing the value of "username" in a POST request.

`ffuf -w /path/to/usernames.txt -u https://example.com/api/login -X POST -H "Content-Type: application/json" -d '{"username":"FUZZ","password":"password"}' -fc 401,403,500 -ac -c -t 100`

## Fuzzing File Upload Endpoints with Custom Headers and Extensions

Fuzzes file upload endpoints with various file extensions and adds multiple custom headers.

`ffuf -w /path/to/filenames.txt -u https://example.com/upload/FUZZ -H "X-Requested-With: XMLHttpRequest" -H "Referer: https://example.com/upload" -e .jpg,.png,.php,.html,.txt -fc 403,404,500 -t 50 -ac -c`

