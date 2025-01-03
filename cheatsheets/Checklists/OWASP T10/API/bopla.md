# Advanced Cheat Sheet: Broken Object Property Level Authorization (BOPLA)

## **What’s Happening?**
Broken Object Property Level Authorization (BOPLA) occurs when an API exposes or allows unauthorized changes to specific object properties that should remain private or restricted. It combines **Excessive Data Exposure (API 3: 2019)** and **Mass Assignment (API 6: 2019)** vulnerabilities.

Think of it as unintentionally giving a user access to sensitive backend information or privileges they shouldn’t have.

---

## **Why It Happens?**

### Example 1: Excessive Data Exposure
#### Request:
```json
{
  "name": "John Wick",
  "email": "johnw@hack.com",
  "payment": "CARD-1234-2345-3456-4567"
}
```

#### Response:
```json
{
  "message": "Ticket booked successfully",
  "Total Revenue Generated": "345298",
  "Discount Coupon_1": "50-OFF",
  "Discount Coupon_2": "80-OFF",
  "Booking Agent Name": "Richard K",
  "Booking Agent ID": "E45262",
  "Total Available Seats": "23",
  "Total Booked Seats": "45"
}
```
Instead of just confirming the booking, the API response exposes sensitive internal data like revenue, discount codes, and employee details.

---

### Example 2: Mass Assignment
#### Ideal Request:
```json
{
  "name": "John Wick",
  "email": "johnw@hack.com",
  "password": "securepassword123"
}
```

#### Malformed Request:
```json
{
  "name": "John Wick",
  "email": "johnw@hack.com",
  "password": "securepassword123",
  "role": "Admin"
}
```
If the backend doesn’t validate inputs properly, the additional `"role": "Admin"` property could escalate privileges unintentionally.

---

## **How to Test for BOPLA**

### 1. **Inspect API Responses**
- Examine all responses to see if they contain unnecessary or sensitive properties.
- Look for internal IDs, system configurations, or financial details.

#### Practical Example:
```bash
curl -X GET https://api.example.com/user/123
```
Check if the response includes sensitive properties such as `role`, `balance`, or `adminStatus`.

---

### 2. **Attempt Unauthorized Property Modification**
- Send requests to modify sensitive properties that shouldn’t be accessible.

#### Practical Example:
```bash
curl -X PUT https://api.example.com/user/123 -d '{"role": "admin"}' -H 'Content-Type: application/json'
```
Observe if the server processes unauthorized role changes.

---

### 3. **Fuzzing**
- Use tools like Burp Suite or custom scripts to send unexpected data to API endpoints.

#### Practical Example:
```bash
fuzzer.py --url https://api.example.com/user --method PUT --fuzz-params
```
Identify hidden or undocumented properties.

---

### 4. **Role Variation Testing**
- Test with accounts of different roles (e.g., admin, user, guest) to check for inconsistent property-level access.

#### Practical Example:
1. Log in as a regular user.
2. Attempt to access or modify properties that should only be accessible by an admin.

---

## **Impact of BOPLA**
- Unauthorized privilege escalation.
- Access to sensitive business or user data.
- Unauthorized modifications to critical properties like account balance, roles, or billing information.

**Severity:** Ranges from **High** to **Critical**, depending on the sensitivity and importance of the exposed or modifiable properties.

---

## **Fixing BOPLA**

### 1. **Implement Property-Level Access Controls**
Ensure that users can only access and modify properties they are explicitly authorized to interact with.

#### Example Fix:
```javascript
if (user.role !== 'admin') {
  delete request.body.role;
}
```

---

### 2. **Limit Data Exposure**
Only return necessary data in API responses.

#### Example Fix:
```javascript
return {
  message: "Ticket booked successfully",
};
```

---

### 3. **Input Validation**
Validate incoming data to prevent unauthorized property modifications.

#### Example Fix:
```javascript
const allowedFields = ["name", "email", "password"];
const sanitizedInput = Object.keys(input).reduce((acc, key) => {
  if (allowedFields.includes(key)) {
    acc[key] = input[key];
  }
  return acc;
}, {});
```

---

### 4. **Regular Security Audits**
Conduct periodic reviews of API endpoints to identify and address potential BOPLA vulnerabilities.

---

## **Advanced Practical Testing Tips**

### Using Burp Suite Extensions
1. **Autorize:** Identify privilege escalation or access control issues by monitoring API requests.
2. **Param Miner:** Discover hidden or undocumented parameters for potential BOPLA exploits.

### Automated Tools
- **OWASP ZAP:** Use its automated scanning capabilities to detect excessive data exposure.
- **Postman:** Automate API tests to send both valid and malformed requests.

### Custom Scripts for Mass Assignment Testing
```python
import requests

url = "https://api.example.com/user/123"
data = {
    "name": "John Doe",
    "role": "admin"
}
response = requests.put(url, json=data)
print(response.text)
```
Check if unauthorized properties are accepted.

---
