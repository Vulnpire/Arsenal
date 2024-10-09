#!/usr/bin/env python3

import re
import sys
import requests
import argparse

email_pattern = re.compile(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")

HUNTER_API_KEY = '' # Your HUNTER API KEY / https://hunter.io/

def validate_email_format(email):
    return bool(email_pattern.match(email))

def check_email_with_hunter(email):
    url = f"https://api.hunter.io/v2/email-verifier?email={email}&api_key={HUNTER_API_KEY}"
    try:
        response = requests.get(url)
        data = response.json()

        if data['data']['result'] == 'undeliverable':
            return False
        if data['data']['result'] == 'deliverable':
            return True
        if data['data']['result'] == 'risky':
            return False
        else:
            return False
    except Exception as e:
        print(f"Error checking email with API: {e}")
        return False

def validate_email(email):
    # print(f"Validating email: {email}")
    if not validate_email_format(email):
        return False, "Invalid format"

    #print(f"Email format valid. Checking with Hunter API: {email}")
    if check_email_with_hunter(email):
        return True, "Valid and registered email"
    else:
        return False, "Undeliverable or risky email"

def main():
    parser = argparse.ArgumentParser(description='Email validation script.')
    parser.add_argument('-o', '--output', action='store_true', help='Output valid and invalid emails to files')

    args = parser.parse_args()

    if sys.stdin.isatty():
        print("Usage: cat input | main.py [-o]")
        sys.exit(1)

    valid_emails = []
    invalid_emails = []

    for line in sys.stdin:
        email = line.strip()
        is_valid, message = validate_email(email)

        if is_valid:
            print(f"Valid: {email}")
            valid_emails.append(email)
        else:
            print(f"Invalid: {email} ({message})")
            invalid_emails.append(email)

    if args.output:
        with open("valid.txt", "w") as valid_file:
            valid_file.write("\n".join(valid_emails))
        with open("invalid.txt", "w") as invalid_file:
            invalid_file.write("\n".join(invalid_emails))

        print("Valid emails saved to valid.txt")
        print("Invalid emails saved to invalid.txt")

if __name__ == "__main__":
    main()