# Favicon Hash Extractor

A Python script that fetches the favicon from a list of URLs, computes its mmh3 hash, and optionally displays verbose error logs.

## Features

- Fetches the `favicon.ico` from a list of URLs.
- Computes the favicon's mmh3 hash, which can be used for Shodan searches.
- Supports verbose mode for logging errors and warnings.

## Requirements

- Python 3.x
- Requests module: `pip3 install requests`
- mmh3 module: `pip3 install mmh3`

## Installation



## Usage

1. **Make the script executable**:

`chmod +x main.py`

2. Pipe URLs from a file:

`cat urls.txt | ./main.py`