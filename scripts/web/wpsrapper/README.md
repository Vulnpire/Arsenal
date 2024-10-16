# WPSWrapper

**WPSWrapper** is a Bash script designed to simplify the use of [WPScan](https://wpscan.com/), a popular WordPress security scanner. This wrapper allows users to easily scan multiple URLs for vulnerabilities while randomizing API keys to prevent overuse of any single key. It also ensures that WPScan is updated before starting any scans.

## Features

- **Randomized API Key Usage**: Automatically selects a random API key from a configuration file for each scan to avoid exceeding usage limits.
- **Input from Standard Input**: Accepts multiple URLs via standard input, making it easy to use with files or other command outputs.
- **Sequential Scanning**: Runs scans one after another, allowing you to monitor progress in real-time.
- **Automatic WPScan Update**: Updates WPScan to the latest version before scanning begins.

## Setup

`bash <(curl -s https://raw.githubusercontent.com/Vulnpire/Arsenal/refs/heads/main/scripts/web/wpsrapper/setup.sh)`
