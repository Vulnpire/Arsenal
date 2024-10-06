package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	"time"
)

const (
	webhookURL = "" // Your Discord Webhook URL
	gistURL    = "https://gist.githubusercontent.com/RedBullSecurity/3eb88debcb01759eccf65ec2b799b340/raw/redbull-bug-bounty-scope-rb-only.txt"
)

var previousURLs []string

func SendDiscordMessage(message string) error {
	jsonStr := fmt.Sprintf(`{"content": "%s"}`, message)
	req, err := http.NewRequest("POST", webhookURL, bytes.NewBuffer([]byte(jsonStr)))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNoContent {
		return fmt.Errorf("failed to send message, status code: %d", resp.StatusCode)
	}
	return nil
}

func fetchGistContent() (string, error) {
	resp, err := http.Get(gistURL)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return string(body), nil
}

func main() {
	if err := SendDiscordMessage("Gistmon is alive!"); err != nil {
		fmt.Println("Error sending startup message:", err)
	}

	for {
		currentContent, err := fetchGistContent()
		if err != nil {
			fmt.Println("Error fetching Gist content:", err)
			time.Sleep(60 * time.Second)
			continue
		}

		currentURLs := strings.Split(currentContent, "\n")

		var newURLs []string
		for _, url := range currentURLs {
			if !contains(previousURLs, url) && url != "" {
				newURLs = append(newURLs, url)
			}
		}

		var deletedURLs []string
		for _, url := range previousURLs {
			if !contains(currentURLs, url) && url != "" {
				deletedURLs = append(deletedURLs, url)
			}
		}

		if len(newURLs) > 0 {
			newMessage := "New URLs added:\n" + strings.Join(newURLs, "\n")
			if err := SendDiscordMessage(newMessage); err != nil {
				fmt.Println("Error sending message to Discord:", err)
			}
			previousURLs = currentURLs
		}

		if len(deletedURLs) > 0 {
			deletedMessage := "URLs deleted:\n" + strings.Join(deletedURLs, "\n")
			if err := SendDiscordMessage(deletedMessage); err != nil {
				fmt.Println("Error sending message to Discord:", err)
			}
			previousURLs = currentURLs
		}

		time.Sleep(60 * time.Second)
	}
}

func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}
