# 🔍 Backend Detector  

A powerful **backend detection script** that identifies server-side technologies, databases, APIs, and authentication mechanisms.  
Built using **WhatWeb** and **cURL**, this script helps distinguish between **static and dynamic** websites.  

## 🚀 Features  
✅ **Detects backend technologies** (PHP, ASP.NET, Node.js, Django, etc.)  
✅ **Identifies databases** (MySQL, PostgreSQL, MongoDB, etc.)  
✅ **Finds CMS platforms** (WordPress, Joomla, Drupal, etc.)  
✅ **Detects API calls** via JavaScript analysis  
✅ **Checks for login/authentication pages**  
✅ **Tests query parameters** to confirm backend processing  
✅ **Supports bulk URL scanning from a file**  

---

## 📦 Installation  

Ensure you have **WhatWeb** and **cURL** installed:  

```bash
sudo apt install whatweb curl -y
```

```bash
curl -s https://raw.githubusercontent.com/Vulnpire/Arsenal/refs/heads/c2/scripts/recon/backend_detect/backend_detect.sh > /tmp/backend_detect.sh && chmod +x /tmp/backend_detect.sh && sudo mv /tmp/backend_detect.sh /usr/local/bin/
```

### Usage

Single URL Scan

```bash
./backend_detect.sh -url https://example.com
```

### Bulk URL Scan

```bash
./backend_detect.sh -file urls.txt
```

### How It Works

    WhatWeb Analysis: Identifies server technologies and CMS.
    Database Detection: Scans for MySQL, PostgreSQL, MongoDB, etc.
    API Discovery: Searches JavaScript files for API calls.
    Login Page Detection: Checks for authentication mechanisms.
    Query Parameter Testing: Determines if the website processes dynamic inputs.
