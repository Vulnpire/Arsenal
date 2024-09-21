# Gist URL Monitor with Discord Notifications

## Features

- Periodically fetches URLs from a Gist file.
- Notifies a Discord webhook when new URLs are added or existing URLs are removed.
- Runs in an infinite loop with a customizable delay (set to 60 seconds by default).

## Prerequisites

Before running the program, ensure you have the following:

- [Go](https://golang.org/doc/install) installed.
- A Discord Webhook URL.
- A Gist URL containing the URLs you want to monitor.

Open the code and replace the placeholders with your values:

    webhookURL - Your Discord webhook URL.
    Gist_URL - The URL of the Gist you want to monitor. (optional)