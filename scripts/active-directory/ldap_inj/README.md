# LDAP Injection Vulnerability Testing

## Overview

This tool demonstrates and tests for **LDAP Injection** vulnerabilities by interacting with vulnerable LDAP directories. LDAP Injection vulnerabilities arise when user-controlled input is improperly sanitized and injected into LDAP queries, potentially allowing an attacker to bypass authentication or access sensitive information.


## Features

- Supports different types of LDAP Injection attacks, including:
  - **Authentication bypass**
  - **Information disclosure**
- Allows testing via both direct input or custom payloads
- Configurable target URLs, including support for piping input
- Lightweight and easy to modify for different LDAP structures

## How It Works

The tool sends crafted LDAP queries to the target directory using injected payloads to explore potential vulnerabilities. When the target does not properly sanitize user input, it can lead to the disclosure of unauthorized information or authentication bypass.

### Example Payload

An LDAP query vulnerable to injection might look like:

`(&(uid=<user_input>)(password=<user_input>))`

If unsanitized, injecting `*)(uid=*))(|(uid=*` into the username field could bypass authentication.

## Build the tool:

`go build -o ldap-injector ldap.go`

## Run the tool:

`echo "http://target-ldap-server/endpoint" | ./ldap-injector`