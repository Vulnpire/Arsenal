import requests
import re

# List of Google Sheets CSV export URLs (one for each sheet)
SPREADSHEET_CSV_URLS = [
    "https://docs.google.com/spreadsheets/d/1CzscF67guNFMy-L_v79ng2mW36dQWb2rQSbK540j-ys/export?format=csv&gid=1281087877",
    "https://docs.google.com/spreadsheets/d/1CzscF67guNFMy-L_v79ng2mW36dQWb2rQSbK540j-ys/export?format=csv&gid=1208823298",
]

KNOWN_ASSETS_FILE = "known_assets.txt"

# Regex patterns
IP_RANGE_REGEX = r"\b(?:\d{1,3}\.){3}\d{1,3}/\d{1,2}\b"
IP_ADDRESS_REGEX = r"\b(?:\d{1,3}\.){3}\d{1,3}\b"
DOMAIN_REGEX = r"\b(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}\b"

def load_known_assets(filepath):
    try:
        with open(filepath, "r") as f:
            return set(line.strip() for line in f)
    except FileNotFoundError:
        return set()

def save_known_assets(filepath, assets):
    with open(filepath, "w") as f:
        for asset in sorted(assets):
            f.write(f"{asset}\n")

def extract_assets(text):
    ip_ranges = set(re.findall(IP_RANGE_REGEX, text))
    all_ips = set(re.findall(IP_ADDRESS_REGEX, text))
    domains = set(re.findall(DOMAIN_REGEX, text))

    # Remove IPs that appear as part of a range to avoid duplication
    plain_ips = all_ips - {ip.split("/")[0] for ip in ip_ranges}

    return ip_ranges.union(plain_ips).union(domains)

def main():
    print("[*] Fetching Google Sheets CSV content from multiple sheets...")
    all_found_assets = set()

    for url in SPREADSHEET_CSV_URLS:
        print(f"[*] Fetching from: {url}")
        response = requests.get(url)
        if response.status_code != 200:
            print(f"[!] Failed to fetch spreadsheet. Status code: {response.status_code}")
            continue

        content = response.text
        found_assets = extract_assets(content)
        all_found_assets.update(found_assets)

    known_assets = load_known_assets(KNOWN_ASSETS_FILE)
    new_assets = all_found_assets - known_assets

    if new_assets:
        print("[+] New assets found:")
        for asset in sorted(new_assets):
            print(f" - {asset}")
        all_assets = known_assets.union(new_assets)
        save_known_assets(KNOWN_ASSETS_FILE, all_assets)
    else:
        print("[-] No new assets found.")

if __name__ == "__main__":
    main()
