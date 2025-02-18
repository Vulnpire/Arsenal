package main

import (
	"bufio"
	"crypto/tls"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/PuerkitoBio/goquery"
)

// Define a regex pattern to detect date formats (e.g., "2025/2/18 12:12")
var datePattern = regexp.MustCompile(`\d{4}/\d{1,2}/\d{1,2} \d{1,2}:\d{2}`)

func main() {
	url := flag.String("u", "", "Target URL with FUZZ placeholder")
	wordlist := flag.String("w", "", "Wordlist file path")
	threads := flag.Int("t", 10, "Number of concurrent requests")
	interactive := flag.Bool("interactive", false, "Show found file contents")
	flag.Parse()

	if *url == "" || *wordlist == "" {
		fmt.Println("Usage: everenum -u <URL with FUZZ> -w <wordlist> [-t <threads>] [-interactive]")
		os.Exit(1)
	}

	paths, err := loadWordlist(*wordlist)
	if err != nil {
		fmt.Printf("[-] Failed to load wordlist: %v\n", err)
		os.Exit(1)
	}

	enumerate(*url, paths, *threads, *interactive)
}

func loadWordlist(filepath string) ([]string, error) {
	file, err := os.Open(filepath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var paths []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		paths = append(paths, scanner.Text())
	}
	return paths, scanner.Err()
}

func enumerate(baseURL string, paths []string, threadCount int, interactive bool) {
	tr := &http.Transport{TLSClientConfig: &tls.Config{InsecureSkipVerify: true}}
	client := &http.Client{Transport: tr, Timeout: 15 * time.Second}

	var wg sync.WaitGroup
	jobs := make(chan string, len(paths))
	results := make(chan string, len(paths))

	for i := 0; i < threadCount; i++ {
		wg.Add(1)
		go worker(client, baseURL, jobs, results, &wg, interactive)
	}

	for _, path := range paths {
		jobs <- path
	}
	close(jobs)

	wg.Wait()
	close(results)

	for result := range results {
		if result != "" {
			fmt.Println(result)
		}
	}
}

func worker(client *http.Client, baseURL string, jobs <-chan string, results chan<- string, wg *sync.WaitGroup, interactive bool) {
	defer wg.Done()

	for path := range jobs {
		targetURL := strings.Replace(baseURL, "FUZZ", path, 1)
		resp, err := fetchWithRetry(client, targetURL, 3)
		if err != nil {
			results <- fmt.Sprintf("[-] Error fetching %s: %v", targetURL, err)
			continue
		}
		defer resp.Body.Close()

		if interactive {
			doc, err := goquery.NewDocumentFromReader(resp.Body)
			if err != nil {
				results <- fmt.Sprintf("[-] Error parsing HTML: %v", err)
				continue
			}

			doc.Find("tr.trdata1").Each(func(i int, s *goquery.Selection) {
				name := s.Find("td.file a").Text()
				path := s.Find("td.pathdata a").Text()
				size := s.Find("td.sizedata").Text()
				modified := s.Find("td.modifieddata").Text()

				if name != "" && path != "" {
					results <- fmt.Sprintf("[+] Found: %s\n    Path: %s\n    Size: %s\n    Modified: %s\n", name, path, size, modified)
				}
			})
		} else {
			body, _ := io.ReadAll(resp.Body)
			if datePattern.Match(body) {
				results <- fmt.Sprintf("[+] Found: %s - Valid", targetURL)
			}
		}
	}
}

func fetchWithRetry(client *http.Client, url string, retries int) (*http.Response, error) {
	var resp *http.Response
	var err error

	for i := 0; i < retries; i++ {
		resp, err = client.Get(url)
		if err == nil && resp.StatusCode < 500 {
			return resp, nil
		}
		time.Sleep(2 * time.Second)
	}
	return nil, err
}
