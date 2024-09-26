# Basic Usage

## Scan a URL with default settings:

`arjun -u https://example.com`

## Specify HTTP methods (GET, POST):

`arjun -u https://example.com -m GET,POST`

## Output results to a text file:

`arjun -u https://example.com -oT output.txt`

## Use a custom wordlist:

`arjun -u https://example.com -w /path/to/wordlist.txt`

## Set the number of threads for faster scanning:

`arjun -u https://example.com -t 10`

## Rate-limit requests per second:

`arjun -u https://example.com --rate-limit 10`

## Add custom headers (e.g., User-Agent):

`arjun -u https://example.com --headers "User-Agent: Mozilla/5.0"`

# Advanced Usage

## Scan multiple URLs from a file:

`arjun -i urls.txt -oT output.txt`

## Specify multiple headers:

`arjun -u https://example.com --headers "User-Agent: Mozilla/5.0" --headers "Cookie: sessionid=abcd1234"`

## Timeout for requests (in seconds):

`arjun -u https://example.com -T 30`

## Output to Burp Suite Proxy:

`arjun -u https://example.com -oB`

## Set Request Delay:

`arjun -u https://example.com -d 2`

## Use Passive Sources:

`arjun -u https://example.com --passive`

## Stable Mode:

`arjun -u https://example.com --stable`

## Include Additional Data in Requests:

`arjun -u https://example.com --include '{"key":"value"}'`

## Disable Redirects:

`arjun -u https://example.com --disable-redirects`

# Common Scenarios

## Scan with GET and POST, using a custom wordlist, output to a file, and with rate limiting:

`arjun -u https://example.com -m GET,POST -w /opt/useful/SecLists/Discovery/Web-Content/burp-parameter-names.txt -oT output.txt -t 10 --rate-limit 10 --disable-redirects --headers "Mozilla/5.0 (Android 10; Mobile; rv:128.0) Gecko/128.0 Firefox/128.0" --headers "X-Forwarded-For: 127.0.0.1"`

## Scan with custom headers and output to a JSON file with a proxy and with 50 chunks:

`arjun -u https://example.com --headers "User-Agent: Mozilla/5.0" -oJ output.json -oB -c 50`
