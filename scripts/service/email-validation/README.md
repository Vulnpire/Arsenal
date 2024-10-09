# Email Validation Script

This Python script validates email addresses by checking their format using a regex pattern and verifying their deliverability using the Hunter.io API. It can handle input from a file or standard input and has an option to output valid and invalid emails into separate files.
Features

- Validates email format using regex.
- Uses the Hunter.io API to check if an email is deliverable or undeliverable.
- Outputs valid and invalid emails into valid.txt and invalid.txt files if specified with the -o flag.
- Can process emails from files or standard input.

## Requirements

    Python 3.x
    requests, re library

You can install the requirements using pip:

pip3 install -r req.txt

## Usage
 
You can pipe email input into the script like this:

`cat emails.txt | ./email_validator.py [-o]`

## Options:

    -o or --output: Save valid emails to valid.txt and invalid emails to invalid.txt.

## API Key Setup

The script uses the Hunter.io API to verify emails. To use the API, replace the placeholder API key with your own Hunter.io API key:

`HUNTER_API_KEY = ''`