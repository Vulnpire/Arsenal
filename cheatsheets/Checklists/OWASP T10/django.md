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

## Tools to Use

- **Burp Suite:** For request interception and vulnerability testing.
- **Nikto:** To scan for misconfigurations.
- **Wappalyzer:** To identify Django and its version.
- **Nmap:** For framework and service fingerprinting.

---

Securing Django applications involves a combination of following best practices, leveraging its built-in security features, and avoiding common developer pitfalls. This checklist not only helps bug bounty hunters but also serves as a guide for developers to secure their applications. By addressing these vulnerabilities, you can ensure a more robust and secure Django deployment.
