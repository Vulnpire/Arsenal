# DoS Testing Tool

## Overview
This is a Denial-of-Service testing tool designed for ethical and authorized security testing of network services. It features multithreading, randomized payloads, support for both TCP and UDP, improved socket handling, and graceful shutdown capabilities.

## Features
- ✅ **Multithreading**: Uses pthreads instead of inefficient process forking.
- ✅ **Randomized Payloads**: Sends dynamically generated ASCII payloads to make testing more effective.
- ✅ **Multiple Protocol Support**: Supports **TCP** (default) and **UDP** for different types of testing.
- ✅ **Improved Socket Handling**: Implements `setsockopt()` for better stability and reconnects on failure.
- ✅ **Graceful Shutdown Handling**: Handles `SIGINT` and `SIGTERM` to ensure clean termination.

## Usage
### Compilation
```sh
gcc -o dos_tool main.c -lpthread
```

### Running the Tool
```sh
./main <target> <port> <tcp|udp>
```
Example:
```sh
./main 192.168.1.100 80 tcp
```
This will launch a multithreaded DoS test on `192.168.1.100` over **TCP port 80**.

For UDP testing:
```sh
./main 192.168.1.100 53 udp
```

## Legal Disclaimer
This tool is intended **only** for ethical security testing with explicit permission from the target owner. Unauthorized use is illegal and may result in severe consequences. The author and contributors are **not responsible** for any misuse.
