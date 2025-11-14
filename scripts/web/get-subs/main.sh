#!/bin/bash

# get-subs - Subdomain Enumeration Script
# Usage: get-subs <domains.txt> -o <output_dir> [-brute] [-portscan]

show_help() {
    echo "Usage: get-subs <domains.txt> -o <output_dir> [-brute] [-portscan]"
    echo ""
    echo "Options:"
    echo "  -o          Output directory (required)"
    echo "  -brute      Enable bruteforce enumeration"
    echo "  -portscan   Run naabu port scan on discovered subdomains"
    echo "  -h, --help  Show this help message"
    exit 1
}

# Parse arguments
INPUT_FILE=""
OUTPUT_DIR=""
BRUTE=false
PORTSCAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -o)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -brute)
            BRUTE=true
            shift
            ;;
        -portscan)
            PORTSCAN=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            if [[ -z "$INPUT_FILE" ]]; then
                INPUT_FILE="$1"
            else
                echo "Error: Unknown argument '$1'"
                show_help
            fi
            shift
            ;;
    esac
done

# Validate inputs
if [[ -z "$INPUT_FILE" ]] || [[ -z "$OUTPUT_DIR" ]]; then
    echo "Error: Missing required arguments"
    show_help
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/sub.txt"

echo "[*] Starting subdomain enumeration"
echo "[*] Input: $INPUT_FILE"
echo "[*] Output: $OUTPUT_FILE"
echo "[*] Bruteforce: $BRUTE"
echo "[*] Port scan: $PORTSCAN"
echo ""

# Subfinder
echo "[+] Running subfinder..."
cat "$INPUT_FILE" | axs -m subfinder -all -recursive -anew "$OUTPUT_FILE"

# Assetfinder
echo "[+] Running assetfinder..."
cat "$INPUT_FILE" | axs -m assetfinder -subs-only -anew "$OUTPUT_DIR/sub.tm"
cat "$OUTPUT_DIR/sub.tm" | sed 's/^\*\.//' | anew -q "$OUTPUT_FILE"
rm -f "$OUTPUT_DIR/sub.tm"

# Shosubgo
echo "[+] Running shosubgo..."
cat "$INPUT_FILE" | axs -m shosubgo -anew "$OUTPUT_FILE"

# Smapper (first pass)
echo "[+] Running smapper..."
cat "$INPUT_FILE" | axs -m smapper -anew "$OUTPUT_FILE"

# Chaos
echo "[+] Running chaos..."
cat "$INPUT_FILE" | axs -m chaos -o "$OUTPUT_DIR/chaos.txt"
cat "$OUTPUT_DIR/chaos.txt" | sed 's/^\*\.//' | sort -u | anew -q "$OUTPUT_FILE"
rm -f "$OUTPUT_DIR/chaos.txt"

# Findomain
echo "[+] Running findomain..."
timeout --foreground 1100 axiom-scan "$INPUT_FILE" -m findomain --external-subdomains --rm-logs -anew "$OUTPUT_FILE"

# Smapper (second pass - check.txt)
if [[ -f "check.txt" ]]; then
    echo "[+] Running smapper on check.txt..."
    cat check.txt | axs -m smapper -anew "$OUTPUT_FILE"
fi

# Banshee
echo "[+] Running banshee..."
banshee -f "$INPUT_FILE" -s | anew "$OUTPUT_FILE"

# Filter by wildcard domains
echo "[+] Filtering results..."
grep -E "$(paste -sd '|' "$INPUT_FILE")" "$OUTPUT_FILE" > "$OUTPUT_DIR/temp"
mv "$OUTPUT_DIR/temp" "$OUTPUT_FILE"

# Remove out-of-scope domains
if [[ -f ~/lists/oos.txt ]]; then
    echo "[+] Removing out-of-scope domains..."
    cat "$OUTPUT_FILE" | vscope -f ~/lists/oos.txt | sort -u > "$OUTPUT_DIR/temp"
    mv "$OUTPUT_DIR/temp" "$OUTPUT_FILE"
fi

# Bruteforce (optional)
if [[ "$BRUTE" == true ]]; then
    echo "[+] Running puredns bruteforce..."
    axiom-scan "$INPUT_FILE" -m puredns-bruteforce -o "$OUTPUT_FILE"
fi

# Final count
TOTAL=$(wc -l < "$OUTPUT_FILE")
echo ""
echo "[✓] Enumeration complete!"
echo "[✓] Total subdomains: $TOTAL"
echo "[✓] Output saved to: $OUTPUT_FILE"

# Port scan (optional)
if [[ "$PORTSCAN" == true ]]; then
    echo ""
    echo "[+] Running naabu port scan..."
    cat "$OUTPUT_FILE" | axs -m naabu -ep 80,443 -o "$OUTPUT_DIR/ports.txt"
    PORT_COUNT=$(wc -l < "$OUTPUT_DIR/ports.txt")
    echo "[✓] Port scan complete!"
    echo "[✓] Results saved to: $OUTPUT_DIR/ports.txt"
    echo "[✓] Total open ports: $PORT_COUNT"
fi
