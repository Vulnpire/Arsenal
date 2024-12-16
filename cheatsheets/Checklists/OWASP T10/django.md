# Checklist for Identifying Django Vulnerabilities

## 1. Debug Mode Exposure

**Risk:** Reveals sensitive information such as environment variables, database credentials, and stack traces.

**How to Test:**
- Check if `DEBUG = True` is enabled by causing errors or accessing common debug URLs (e.g., `/debug/`).

**Example:**
- Trigger an error by visiting a non-existent URL, such as `/nonexistent-page/`. If debug mode is enabled, a detailed error page with stack trace and environment variables will be displayed.

**Remediation:**
- Always set `DEBUG = False` in production.

---

## 2. CSRF (Cross-Site Request Forgery)

**Risk:** Django provides CSRF protection, but misconfigurations or using `@csrf_exempt` can make endpoints vulnerable.

**How to Test:**
- Identify POST/PUT requests and remove the `csrfmiddlewaretoken`.
- Use tools like Burp Suite to craft malicious CSRF payloads.

**Example:**
- Create a malicious HTML form that submits a POST request to the target endpoint:
  ```html
  <form action="http://target-site.com/endpoint" method="POST">
      <input type="hidden" name="data" value="malicious_value">
      <input type="submit">
  </form>
  ```

**Remediation:**
- Avoid using `@csrf_exempt` unless absolutely necessary.

---

## 3. Cross-Site Scripting (XSS)

**Risk:** XSS can occur if developers disable Django’s auto-escaping in templates (e.g., using `|safe`).

**How to Test:**
- Inject `<script>alert(1)</script>` in input fields or query parameters.
- Look for reflected or stored payloads in responses.

**Example:**
- Test a search bar by entering `<script>alert('XSS')</script>`. If the alert executes, the input is vulnerable.

**Remediation:**
- Avoid using `|safe` unless sanitizing input properly.

---

## 4. SQL Injection

**Risk:** Using raw SQL queries without parameterized inputs can lead to SQLi.

**How to Test:**
- Inject SQL payloads like `' OR 1=1--` into query parameters or form inputs.

**Example:**
- Enter `' OR 1=1--` in a login form username field. If login succeeds without a password, the application is vulnerable.

**Remediation:**
- Use Django ORM instead of raw queries, or ensure proper parameterization.

---

## 5. Sensitive Data Exposure

**Risk:** Exposing sensitive files like `.env`, `settings.py`, or database dumps can lead to data leaks.

**How to Test:**
- Use tools like Burp Suite or directory brute-forcing tools to locate sensitive files.
- Look for hardcoded API keys or credentials in responses.

**Example:**
- Attempt accessing `http://target-site.com/.env` or `http://target-site.com/settings.py`. If accessible, sensitive data might be exposed.

**Remediation:**
- Restrict access to sensitive files using proper file permissions and server configurations.

---

## 6. Insecure Authentication and Authorization

**Risk:** Misconfigured authentication mechanisms or missing `@login_required` decorators can lead to unauthorized access.

**How to Test:**
- Attempt accessing restricted endpoints as an unauthenticated user.
- Test privilege escalation by modifying user IDs in API requests.

**Example:**
- Change the `user_id` parameter in an API request from `123` to `124`. If you can access another user’s data, privilege escalation is possible.

**Remediation:**
- Use `@login_required` or `@permission_required` decorators wherever necessary.

---

## 7. Missing Security Headers

**Risk:** Missing headers like `Strict-Transport-Security`, `Content-Security-Policy`, or `X-Frame-Options` can expose the application to attacks.

**How to Test:**
- Use tools like SecurityHeaders or Burp Suite to check response headers.

**Example:**
- Analyze the response headers of a page. If `X-Frame-Options` is missing, the page might be vulnerable to clickjacking.

**Remediation:**
- Enable `SecurityMiddleware` and configure headers.

---

## 8. Improper File Upload Handling

**Risk:** Allowing unrestricted file uploads can lead to RCE or DoS attacks.

**How to Test:**
- Upload malicious files like `.php`, `.exe`, or scripts and check for execution or improper validation.

**Example:**
- Upload a file named `shell.php` with the content:
  ```php
  <?php system($_GET['cmd']); ?>
  ```
  Access the file and execute commands by appending `?cmd=ls`.

**Remediation:**
- Validate file types and use secure upload directories.

---

## 9. Admin Panel Exposure

**Risk:** Exposed admin panels can be brute-forced or accessed by unauthorized users.

**How to Test:**
- Attempt accessing `/admin` or other known admin paths.
- Test for weak credentials or lack of account lockouts.

**Example:**
- Use a dictionary attack to brute-force the admin login.

**Remediation:**
- Restrict admin access by IP or enforce two-factor authentication.

---

## 10. Directory Traversal

**Risk:** Improper handling of file paths can lead to unauthorized access to system files.

**How to Test:**
- Use payloads like `../../etc/passwd` to traverse directories.

**Example:**
- Submit `../../etc/passwd` in a file path parameter. If the contents of the file are displayed, the application is vulnerable.

**Remediation:**
- Sanitize user input for file paths and use secure file APIs.

---

## 11. Open Redirects

**Risk:** Open redirects can allow attackers to redirect users to malicious sites, enabling phishing attacks.

**How to Test:**
- Identify endpoints with redirect functionality (e.g., `next` or `url` parameters).
- Test by injecting external URLs like `http://malicious-site.com`.

**Example:**
- Access a URL like `http://target-site.com/redirect?next=http://malicious-site.com`. If you are redirected to the malicious site, the application is vulnerable.

**Remediation:**
- Validate and sanitize redirect URLs, ensuring they point only to trusted domains.

---

## 12. Insufficient Session Expiration

**Risk:** Sessions that do not expire appropriately can allow unauthorized access if a session token is stolen.

**How to Test:**
- Check session expiration settings in cookies.
- Test if a session remains valid after logout or inactivity.

**Example:**
- Log in to the application, copy the session token, log out, and reuse the token to access the application.

**Remediation:**
- Set appropriate session expiration times and ensure tokens are invalidated on logout.

---

## 13. Rate Limiting Issues

**Risk:** Lack of rate limiting can lead to brute-force attacks or abuse of endpoints.

**How to Test:**
- Use tools like Burp Suite or Hydra to send multiple requests to login or API endpoints.
- Check for account lockouts or error responses after repeated attempts.

**Example:**
- Attempt 100 login requests with different passwords for the same username. If there is no lockout or delay, the application is vulnerable.

**Remediation:**
- Implement rate limiting using Django’s `axes` or third-party libraries.

---

## 14. Weak Password Policies

**Risk:** Weak password policies can allow users to set easily guessable passwords.

**How to Test:**
- Register or update an account with a weak password like `password123` or `12345678`.

**Example:**
- If the application accepts weak passwords, it is vulnerable to credential stuffing.

**Remediation:**
- Enforce strong password policies using Django’s `AUTH_PASSWORD_VALIDATORS`.

---

## 15. Exposure of API Endpoints

**Risk:** Unprotected or undocumented API endpoints can expose sensitive functionality.

**How to Test:**
- Use tools like Burp Suite or Postman to enumerate API endpoints.
- Check for endpoints that bypass authentication or perform sensitive operations.

**Example:**
- Access an endpoint like `/api/delete-user/` without authentication. If the operation succeeds, the endpoint is vulnerable.

**Remediation:**
- Document all API endpoints and ensure proper authentication and authorization.

---

## 16. Insecure Caching

**Risk:** Sensitive data stored in caches can be exposed to unauthorized users.

## Tools to Use

- **Burp Suite:** For request interception and vulnerability testing.
- **Nikto:** To scan for misconfigurations.
- **Wappalyzer:** To identify Django and its version.
- **Nmap:** For framework and service fingerprinting.

---

