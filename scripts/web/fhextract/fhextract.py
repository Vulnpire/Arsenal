#!/usr/bin/env python3

import mmh3
import requests
import codecs
import sys

def get_favicon_hash(url, verbose=False):
    if not url.endswith('/favicon.ico'):
        url = url.rstrip('/') + '/favicon.ico'
    
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            favicon = codecs.encode(response.content, "base64")
            hash_value = mmh3.hash(favicon)
            return hash_value
        elif verbose:
            print(f"Failed to fetch favicon for {url} (HTTP {response.status_code})")
        return None
    except requests.exceptions.RequestException as e:
        if verbose:
            print(f"Error fetching favicon from {url}: {str(e)}")
        return None

if __name__ == "__main__":
    verbose = '-v' in sys.argv

    for line in sys.stdin:
        url = line.strip()
        if url:
            hash_value = get_favicon_hash(url, verbose)
            if hash_value is not None:
                if verbose:
                    print(f"{url}: {hash_value}")
                else:
                    print(hash_value)
