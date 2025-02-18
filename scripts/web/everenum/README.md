# EverEnum

is a **high-performance enumeration tool** designed for **penetration testers** and **bug bounty hunters**. It automates **fuzzing** for sensitive files, credentials, logs, and misconfigurations across web applications and APIs.

## 🚀 Features

- **Multi-threaded execution** for fast enumeration
- **Custom wordlist support** with an extensive built-in list of sensitive files
- **TLS verification bypass** for scanning misconfigured HTTPS endpoints
- **Interactive mode (-interactive)** for detailed output, including file contents
- **Automatic detection of timestamps in responses**
- **Clean and formatted output** for better readability
- **Retry logic** for handling network timeouts

## 🛠️ Usage

```bash
./everenum -u <URL with FUZZ> -w <wordlist> [-t <threads>] [-interactive]
```

### Example

```bash
./everenum -u "https://example.com/?search=FUZZ" -w wordlist.txt -t 20 -interactive
```

### Options

| Flag            | Description                                |
|----------------|--------------------------------------------|
| `-u`           | Target URL with `FUZZ` placeholder        |
| `-w`           | Path to wordlist file                     |
| `-t`           | Number of concurrent requests (default: 10) |
| `-interactive` | Display found file contents & details     |

## 📂 Wordlist

EverEnum comes with a **comprehensive wordlist** covering:

- **Configuration files** (`config.ini`, `wp-config.php`, `.env`, etc.)
- **Database dumps** (`db_backup.sql`, `schema.sql`, etc.)
- **Credentials & authentication** (`passwords.txt`, `id_rsa`, `tokens`)
- **Logs & debugging files** (`error.log`, `access.log`, `debug.log`)
- **Cloud & API keys** (`aws_keys`, `firebase.json`, `jwt`, `api_secret`)
- **Crypto wallets & encryption keys** (`wallet.dat`, `keystore.json`, `cert.pfx`)

The built-in list contains **300+ high-value targets**! You can also provide your own wordlist using `-w`.

## 🛑 Disclaimer

This tool is intended **only for ethical security testing** and **bug bounty hunting**. Unauthorized use against systems **without permission** is illegal. **I am not responsible for any misuse.**

---

Happy hacking! 🏴‍☠️

