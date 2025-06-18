# vscope

`vscope` is a simple yet powerful Bash tool designed for filtering out out-of-scope subdomains and directories from a list of URLs. It's especially useful for security researchers, bug bounty hunters, and penetration testers who want to exclude known out-of-scope assets during their reconnaissance or scanning phases.

## 🧠 Features

- Filters out full domains and specific paths.
- Supports wildcard-style path matching.
- Lightweight and fast — perfect for pipelines and automation.
- Designed for production use.

## 🚀 Usage

```bash
cat urls.txt | ./vscope -f path/to/oos.txt
```

Example

Given:

urls.txt

```
https://fraga.atg.se
https://example.com
https://shop.atg.se/cart
https://blog.bitoasis.net
https://store.doctolib.com
https://safe.domain.com

```

oos.txt

```
fraga.atg.se
shop.atg.se
blog.bitoasis.net
store.doctolib.com

```

Run:

`cat urls.txt | ./vscope -f oos.txt`

https://example.com
https://safe.domain.com

Out-of-Scope File Format (-f flag)

Each line of the OOS file can contain:

    Domains (e.g., sub.example.com)

    Paths (e.g., example.com/secret)

    Specific files (e.g., example.com/main.js)
