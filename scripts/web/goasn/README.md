# goasn

is a simple Go tool that fetches ASN (Autonomous System Number) information from bgp.he.net for a given domain. It supports input from either stdin or a file and can output results in both standard and verbose modes.

## Features

    Fetch ASN Information: Retrieves ASN numbers from bgp.he.net for a given domain.
    Input Support: Accepts input via stdin or from a file.

## Installation

Build the tool using Go:

`go build -o goasn goasn.go`

Move the goasn binary to your PATH (optional):

sudo mv goasn ~/go/bin/

## Usage

Fetch ASN for a single domain via stdin:

`echo "domain.tld" | ./goasn`

Fetch ASN for multiple domains from a file:

`cat urls.txt | ./goasn`

## Example

`$ echo "example.tld" | ./goasn`

AS1337

`cat urls.txt | ./goasn | asnmap -silent | tlsx -cn -san -silent -resp-only`

Get the IP ranges from Shodan:

`echo intigriti.com | ./goasn | asnmap -silent | sXtract -ir`

2.57.12.1
2.255.190.5
2.255.190.6
...