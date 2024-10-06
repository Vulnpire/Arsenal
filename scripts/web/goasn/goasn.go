package main

import (
        "bufio"
        "flag"
        "fmt"
        "net/http"
        "os"
        "regexp"
        "strings"

        "github.com/PuerkitoBio/goquery"
)

func searchASN(query string, verbose bool) {
        // regex to detect if the input is a domain
        isDomain := regexp.MustCompile(`\.[a-zA-Z]{2,}$`)

        var url string
        if isDomain.MatchString(query) {
                // search by domain
                url = "https://bgp.he.net/dns/" + query
        } else {
                // search by organization name
                url = "https://bgp.he.net/search?search%5Bsearch%5D=" + query + "&commit=Search"
        }

        resp, err := http.Get(url)
        if err != nil {
                fmt.Println("Error fetching the page:", err)
                return
        }
        defer resp.Body.Close()

        if resp.StatusCode != 200 {
                fmt.Println("Failed to fetch the page. Status code:", resp.StatusCode)
                return
        }

        // goquery to parse the results
        doc, err := goquery.NewDocumentFromReader(resp.Body)
        if err != nil {
                fmt.Println("Error reading the page:", err)
                return
        }

        // scrape ASN numbers
        doc.Find("a").Each(func(i int, s *goquery.Selection) {
                asn := s.Text()
                if strings.HasPrefix(asn, "AS") {
                        if verbose {
                                fmt.Printf("ASN for %s: %s\n", query, asn)
                        } else {
                                fmt.Println(asn)
                        }
                }
        })
}

func main() {
        var file string
        var verbose bool
        flag.StringVar(&file, "f", "", "Input file containing domains or organization names")
        flag.BoolVar(&verbose, "v", false, "Enable verbose mode")
        flag.Parse()

        if file != "" {
                f, err := os.Open(file)
                if err != nil {
                        fmt.Println("Error opening file:", err)
                        return
                }
                defer f.Close()

                scanner := bufio.NewScanner(f)
                for scanner.Scan() {
                        query := scanner.Text()
                        searchASN(query, verbose)
                }

                if err := scanner.Err(); err != nil {
                        fmt.Println("Error reading file:", err)
                }
        } else {
                scanner := bufio.NewScanner(os.Stdin)
                for scanner.Scan() {
                        query := scanner.Text()
                        searchASN(query, verbose)
                }
        }
}