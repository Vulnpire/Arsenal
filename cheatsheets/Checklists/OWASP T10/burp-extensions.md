# Burp Suite Extensions Cheat Sheet

## 1. **Autorize**
**Creator:** Barak Tawily  
**Purpose:** Automates the process of identifying authorization flaws, such as privilege escalation or access control issues.  

### Usage
1. Install from the BApp Store.
2. Configure the authenticated and unauthenticated cookies or headers in the settings.
3. Let the extension monitor requests for authorization vulnerabilities.

### Why It's Popular
Saves time by automating tedious checks for access control issues.

#### Practical Example
- Set up an authenticated session in Burp.
- Intercept requests and allow Autorize to compare authenticated and unauthenticated responses.
- Identify unauthorized data access or privilege escalation vulnerabilities.

---

## 2. **Param Miner**
**Creator:** James Kettle  
**Purpose:** Discovers hidden parameters that could reveal new attack vectors.  

### Usage
1. Install from the BApp Store.
2. Right-click on a request and choose "Guess Parameters."
3. Analyze the results in the output tab.

### Why It's Popular
Great for uncovering undocumented or overlooked parameters that may lead to vulnerabilities.

#### Practical Example
- Use Param Miner to identify parameters like `debug`, `test`, or `admin` in endpoints.
- Test discovered parameters for sensitive data exposure or misconfigurations.

---

## 3. **HTTP Request Smuggler**
**Creator:** James Kettle  
**Purpose:** Identifies HTTP request smuggling vulnerabilities, a common issue in complex server setups.  

### Usage
1. Install from the BApp Store.
2. Send a request to Repeater and analyze it using the extension.
3. Look for anomalies in how requests are processed.

### Why It's Popular
Helps find high-severity vulnerabilities often overlooked by automated scanners.

#### Practical Example
- Test for differences in `Content-Length` and `Transfer-Encoding` headers to identify smuggling issues.
- Exploit smuggled requests to bypass security controls or access restricted areas.

---

## 4. **Turbo Intruder**
**Creator:** James Kettle  
**Purpose:** A high-speed fuzzer designed for efficiently sending massive payloads.  

### Usage
1. Install from the BApp Store.
2. Send a request to Turbo Intruder.
3. Customize the provided Python script to define your payloads.
4. Run and analyze the results.

### Why It's Popular
Handles large-scale brute-force and fuzzing tasks with ease.

#### Practical Example
- Use Turbo Intruder to brute-force login pages or fuzz API endpoints for hidden parameters.

---

## 5. **Logger++**
**Creator:** Unknown (Open-source Community)  
**Purpose:** Provides detailed logging of HTTP requests and responses for debugging complex workflows.  

### Usage
1. Install from the BApp Store.
2. Customize filters to log specific traffic.
3. Monitor and analyze logs in real time.

### Why It's Popular
Simplifies the process of keeping track of requests during complex testing.

#### Practical Example
- Log all requests and filter traffic to specific domains or endpoints.
- Identify unexpected redirects or anomalies in headers.

---

## 6. **Hackvertor**
**Creator:** Gareth Heyes  
**Purpose:** Converts, encodes, and decodes payloads to help craft complex attacks.  

### Usage
1. Install from the BApp Store.
2. Use Hackvertor syntax to encode payloads directly within Burp Suite.
3. Test your payloads efficiently.

### Why It's Popular
Essential for crafting payloads for XSS, SQLi, and other injection attacks.

#### Practical Example
- Convert payloads to Base64, URL-encode them, and test injection points.
- Use Hackvertor to encode special characters and bypass filters.

---

## 7. **JWT Editor**
**Creator:** PortSwigger Research Team  
**Purpose:** Modifies and resigns JSON Web Tokens to test authentication mechanisms.  

### Usage
1. Install from the BApp Store.
2. Right-click on a JWT and select "Edit and Resign JWT."
3. Modify claims or signatures and resend the token.

### Why It's Popular
Enables quick testing of JWT vulnerabilities like signature validation bypass or token tampering.

#### Practical Example
- Change `admin=false` to `admin=true` in the JWT payload and resend the token.
- Test for weak or missing signature validation.

---

## 8. **Paramalyzer**
**Creator:** Unknown (Open-source Community)  
**Purpose:** Analyzes and groups parameters from multiple requests to find anomalies.  

### Usage
1. Install from the BApp Store.
2. Intercept traffic through Burp and let the extension analyze parameters.
3. Review findings to identify duplicate, unused, or misconfigured parameters.

### Why It's Popular
Saves time during recon and parameter analysis.

#### Practical Example
- Identify unusual query parameters that may indicate hidden features or debug modes.

---

## 9. **AuthMatrix**
**Creator:** NetSPI Team  
**Purpose:** Tests for authorization flaws using matrix-based testing.  

### Usage
1. Install from the BApp Store.
2. Configure roles and permissions in the matrix.
3. Intercept requests, and AuthMatrix will highlight discrepancies.

### Why It's Popular
Provides a clear, visual way to test access control issues.

#### Practical Example
- Set up user roles (e.g., admin, user, guest) and test resource access for each role to identify privilege escalation.

---

## 10. **Burp Beautifier**
**Creator:** Unknown (Open-source Community)  
**Purpose:** Formats JSON, XML, and other data for easy readability.  

### Usage
1. Install from the BApp Store.
2. Right-click on a response and choose "Beautify."
3. View the formatted output.

### Why It's Popular
Simplifies analyzing encoded or complex responses.

#### Practical Example
- Beautify a large JSON response to easily spot sensitive information or unusual values.

### 11. **Retire.js**
**Purpose:** Detects outdated JavaScript libraries that may have known vulnerabilities.  
**Practical Use:** Identify vulnerable JavaScript dependencies by scanning web application assets.

### 12. **Burp Bounty**
**Purpose:** Automates custom scan checks and helps identify specific vulnerabilities.  
**Practical Use:** Create or use predefined scan profiles to automate checks for common vulnerabilities like SQL injection or XSS.

### 13. **JSON Web Tokens Attacker**
**Purpose:** Focuses on advanced JWT vulnerabilities like key injection and algorithm spoofing.  
**Practical Use:** Test for insecure JWT implementations, including the `none` algorithm bypass.

### 14. **CSP Auditor**
**Purpose:** Analyzes Content Security Policies to identify bypass techniques.  
**Practical Use:** Evaluate the strength of a website’s CSP and look for weak directives or unsafe configurations.

### 15. **Active Scan++**
**Purpose:** Enhances Burp’s active scanning with additional tests and payloads.  
**Practical Use:** Identify less common vulnerabilities by running advanced scan checks.

### 16. **Request Timer**
**Purpose:** Measures response times for requests to detect potential timing attacks.  
**Practical Use:** Use response time differences to detect blind SQL injection or other timing-based vulnerabilities.

### 17. **Backslash Powered Scanner**
**Purpose:** Identifies injection vulnerabilities by inserting various payloads with backslashes.  
**Practical Use:** Detect template injection, SQL injection, and command injection vulnerabilities effectively.

### 18. **Software Vulnerability Scanner**
**Purpose:** Identifies known vulnerabilities in software versions exposed in headers or responses.  
**Practical Use:** Use the scanner to correlate version numbers with known CVEs (Common Vulnerabilities and Exposures).

### 19. **Clickbandit**
**Purpose:** Detects clickjacking vulnerabilities.  
**Practical Use:** Test whether a website’s UI can be framed, exposing it to clickjacking attacks.

### 20. **Session Tracking Client**
**Purpose:** Monitors session tokens and highlights anomalies.  
**Practical Use:** Test for session fixation or predictability issues by analyzing token behavior during authentication flows.

---https://devilwrites.medium.com/api-pentesting-broken-object-property-level-authorization-21d65939ad24https://devilwrites.medium.com/api-pentesting-broken-object-property-level-authorization-21d65939ad24https://devilwrites.medium.com/api-pentesting-broken-object-property-level-authorization-21d65939ad24https://devilwrites.medium.com/api-pentesting-broken-object-property-level-authorization-21d65939ad24https://devilwrites.medium.com/api-pentesting-broken-object-property-level-authorization-21d65939ad24https://devilwrites.medium.com/api-pentesting-broken-object-property-level-authorization-21d65939ad24https://devilwrites.medium.com/api-pentesting-broken-object-property-level-authorization-21d65939ad24

