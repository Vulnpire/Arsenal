package main

import (
	"bufio"
	"flag"
	"fmt"
	"net/url"
	"os"
	"strings"
	"errors"
)

func main() {
	// Parse command-line flags
	encodeTimes := flag.Int("w", 1, "Number of times to encode the URL")
	decode := flag.Bool("d", false, "Decode the URL instead of encoding")
	flag.Parse()

	// Create a new scanner to read from standard input
	scanner := bufio.NewScanner(os.Stdin)
	
	// Loop through each line of input
	for scanner.Scan() {
		// Read the current line
		line := scanner.Text()
		var result string
		var err error
		
		if *decode {
			result, err = decodeURL(line)
		} else {
			result = encodeURL(line, *encodeTimes)
		}

		if err != nil {
			fmt.Fprintln(os.Stderr, "error:", err)
			os.Exit(1)
		}

		// Print the final result
		fmt.Println(result)
	}

	// Handle any scanning errors
	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}

// Function to encode a URL multiple times
func encodeURL(input string, times int) string {
	encoded := strings.TrimSpace(input)
	for i := 0; i < times; i++ {
		encoded = url.QueryEscape(encoded)
	}
	return encoded
}

// Function to decode a URL
func decodeURL(input string) (string, error) {
	decoded := strings.TrimSpace(input)
	var err error
	for {
		decoded, err = url.QueryUnescape(decoded)
		if err != nil {
			return "", errors.New("invalid URL encoding")
		}
		if !strings.Contains(decoded, "%") {
			break
		}
	}
	return decoded, nil
}
