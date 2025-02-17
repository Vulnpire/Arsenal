import tkinter as tk
from tkinter import ttk, messagebox
from scapy.all import sniff, IP, TCP, UDP, ICMP, get_if_list
import threading
import os
import sys

def check_sudo():
    if os.geteuid() != 0:
        messagebox.showerror("Permission Error", "This script requires sudo privileges.")
        sys.exit(1)

# A message box should show an error, and the script should exit.

def get_active_interface():
    interfaces = get_if_list()
    for iface in interfaces:
        if "eth" in iface or "wlan" in iface or "en" in iface:
            return iface
    return "eth0" 

# Should fall back to "eth0" without crashing

def packet_callback(packet):
    if packet.haslayer(IP):
        src_ip = packet[IP].src
        dst_ip = packet[IP].dst
        proto = "TCP" if packet.haslayer(TCP) else "UDP" if packet.haslayer(UDP) else "ICMP" if packet.haslayer(ICMP) else "Other"
        
        if (not src_filter.get() or src_filter.get() in src_ip) and \
           (not dst_filter.get() or dst_filter.get() in dst_ip) and \
           (not proto_filter.get() or proto_filter.get().upper() == proto):
            tree.insert("", tk.END, values=(src_ip, dst_ip, proto))

# Capturing packets with filters set
# Only packets matching the filter should be displayed

def start_sniffing():
    global sniffing
    sniffing = True
    start_button.config(state=tk.DISABLED)
    stop_button.config(state=tk.NORMAL)
    iface = get_active_interface()
    threading.Thread(target=lambda: sniff(prn=packet_callback, store=False, stop_filter=lambda x: not sniffing, iface=iface), daemon=True).start()

# Starting packet capture on an active network
# Packets should start appearing in the table

def stop_sniffing():
    global sniffing
    sniffing = False
    start_button.config(state=tk.NORMAL)
    stop_button.config(state=tk.DISABLED)
    messagebox.showinfo("Info", "Packet capturing stopped.")

# Clicking stop capture while packets are being captured
# Capture should stop, and no more packets should be added

def clear_table():
    for item in tree.get_children():
        tree.delete(item)

# Clearing the table after packets are captured
# The table should be empty now after clicking "Clear Table"

def export_data():
    with open("captured_packets.csv", "w") as f:
        f.write("Source IP,Destination IP,Protocol\n")
        for item in tree.get_children():
            f.write(",".join(tree.item(item, "values")) + "\n")
    messagebox.showinfo("Export", "Data saved as captured_packets.csv")

# Exporting data after capturing packets
# The CSV file should contain the captured packet data

check_sudo()

root = tk.Tk()
root.title("NetFlow Packet Capture")
root.geometry("500x400")

frame = tk.Frame(root)
frame.pack(pady=10)

tk.Label(frame, text="Source IP:").grid(row=0, column=0)
src_filter = tk.Entry(frame)
src_filter.grid(row=0, column=1)

tk.Label(frame, text="Destination IP:").grid(row=1, column=0)
dst_filter = tk.Entry(frame)
dst_filter.grid(row=1, column=1)

tk.Label(frame, text="Protocol (TCP/UDP/ICMP):").grid(row=2, column=0)
proto_filter = tk.Entry(frame)
proto_filter.grid(row=2, column=1)

start_button = tk.Button(frame, text="Start Capture", command=start_sniffing)
start_button.grid(row=3, column=0, pady=5)

stop_button = tk.Button(frame, text="Stop Capture", command=stop_sniffing, state=tk.DISABLED)
stop_button.grid(row=3, column=1, pady=5)

clear_button = tk.Button(frame, text="Clear Table", command=clear_table)
clear_button.grid(row=4, column=0, pady=5)

export_button = tk.Button(frame, text="Export Data", command=export_data)
export_button.grid(row=4, column=1, pady=5)

columns = ("Source IP", "Destination IP", "Protocol")
tree = ttk.Treeview(root, columns=columns, show="headings")
for col in columns:
    tree.heading(col, text=col)
    tree.column(col, width=150)
tree.pack(pady=10)

sniffing = False

root.after(100, start_sniffing)

root.mainloop()
