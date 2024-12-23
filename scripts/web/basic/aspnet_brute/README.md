PoC Exploit to Bypass Brute Force Mechanisms on http://aspnet.testsparker.com/administrator/Login.aspx?r=/Dashboard/&newAuth=1

![image](https://github.com/user-attachments/assets/9116fc30-91df-4ca9-8e83-992edfc25945)

This Proof of Concept (DEMO) demonstrates how to bypass the brute force protection mechanism on the login page of http://aspnet.testsparker.com/administrator/Login.aspx. The exploit leverages CAPTCHA bypass techniques by decoding and solving the CAPTCHA image, enabling automated login attempts with a password wordlist.

Prerequisites

To run this exploit, you need the following dependencies:

    Python 3.x
    requests: For making HTTP requests.
    pytesseract: For extracting text from CAPTCHA images.
    Pillow (PIL): For handling images.
    base64: For decoding base64-encoded CAPTCHA images.

You can install the necessary Python libraries using pip:

`pip3 install requests pytesseract Pillow`

Script Overview

The script automates the process of brute-forcing the login page by:

    Fetching the CAPTCHA from the login page.
    Decoding and extracting the CAPTCHA text using OCR (Optical Character Recognition).
    Trying different passwords from a provided wordlist while submitting the CAPTCHA solution.

How It Works

    CAPTCHA Extraction: The script fetches the login page and extracts the CAPTCHA image encoded in base64 format.
    CAPTCHA Decoding: The base64-encoded CAPTCHA is decoded, and the text is extracted using pytesseract, a Python OCR tool.
    Login Attempts: For each password in the provided wordlist, the script submits the email, password, and CAPTCHA text to the login form.
    Login Success Check: The script checks if the login was successful by looking for specific success messages in the response.

# Script Breakdown

decode_captcha(base64_captcha)

    Purpose: Decodes the base64-encoded CAPTCHA image and extracts the alphanumeric CAPTCHA text.
    Input: A base64-encoded CAPTCHA string.
    Output: The decoded CAPTCHA text, or None if an error occurs.

fetch_captcha(session, url)

    Purpose: Fetches the login page and extracts the base64-encoded CAPTCHA image.
    Input: A requests.Session object and the login URL.
    Output: The base64-encoded CAPTCHA string, or None if the CAPTCHA is not found.

main()

    Purpose: The main entry point for the script. It reads the wordlist, fetches and decodes the CAPTCHA, and attempts to log in with each password.
    Input: The path to the wordlist file.
    Output: Logs the results of each login attempt and prints the successful password if the login is successful.
