# NetFlow Packet Capture GUI

NetFlow Packet Capture GUI is a Python-based tool for real-time network traffic monitoring. It uses `Scapy` for packet sniffing and `Tkinter` for a graphical user interface (GUI), allowing users to filter and analyze network traffic based on source IP, destination IP, and protocol.

## Features
- **Real-time packet capturing**
- **Filter by source IP, destination IP, and protocol (TCP/UDP/ICMP)**
- **Start and stop capturing with a simple GUI**
- **Export captured packets to CSV**
- **Capture only NetFlow packets (UDP on port 2055)**
- **Requires sudo privileges for packet sniffing**

## Installation
### Prerequisites
- Python 3.10+
- `pip` (Python package manager)

### Install Dependencies
```bash
pip install -r requirements.txt
```

#### Required Python Packages:
```bash
pip install scapy tkinter
```

> Note: `tkinter` is included in standard Python installations but may need to be installed separately on some distributions.

## Usage
### Running the GUI
```bash
sudo python3 main.py
```
> **sudo** is required to capture network packets.

### Using the GUI
1. Enter filters for source IP, destination IP, and protocol (optional).
2. Click `Start Capture` to begin sniffing.
3. Click `Stop Capture` to stop.
4. Click `Export Data` to save captured packets to `captured_packets.csv`.

## Converting to an Executable (Windows)
To generate a standalone `.exe` file:
```bash
pyinstaller --onefile --windowed --uac-admin main.py
```
> The `--uac-admin` flag ensures the executable runs with admin privileges.

## Troubleshooting
### "pyinstaller: command not found"
Ensure `pyinstaller` is installed:
```bash
pip install pyinstaller
```
If the issue persists, add `pyinstaller` to your system path or use the full path to execute it.

### "Permission Error: This script requires sudo privileges"
Run the script with `sudo`:
```bash
sudo python3 main.py
```
