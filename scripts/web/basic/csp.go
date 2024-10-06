package main

import (
    "context"
    "fmt"
    "io/ioutil"
    "log"
    "net/http"
    "os"
    "regexp"
    "strings"
    "sync"
    "time"

    "github.com/chromedp/chromedp"
    "github.com/chromedp/cdproto/network"
)

func main() {
    if len(os.Args) < 2 {
        log.Fatalf("Usage: %s <URL>", os.Args[0])
    }
    targetURL := os.Args[1]

    ctx, cancel := chromedp.NewExecAllocator(context.Background(), chromedp.Flag("headless", true))
    defer cancel()

    ctx, cancel = chromedp.NewContext(ctx)
    defer cancel()

    ctx, cancel = context.WithTimeout(ctx, 30*time.Second)
    defer cancel()

    var scriptURLs []string
    cspHeaders := make(map[string]bool)

    chromedp.ListenTarget(ctx, func(ev interface{}) {
        switch evt := ev.(type) {
        case *network.EventRequestWillBeSent:
            if evt.Type == network.ResourceTypeScript {
                scriptURLs = append(scriptURLs, evt.Request.URL)
            }
        case *network.EventResponseReceived:
            for name, value := range evt.Response.Headers {
                if strings.Contains(strings.ToLower(name), "csp") {
                    if v, ok := value.(string); ok {
                        cspHeaders[v] = true
                    }
                }
            }
        }
    })

    if err := chromedp.Run(ctx, network.Enable(), chromedp.Navigate(targetURL), chromedp.Sleep(2*time.Second)); err != nil {
        log.Fatalf("Failed to navigate: %v", err)
    }

    domains := make(map[string]struct{})
    var wg sync.WaitGroup

    for cspHeader := range cspHeaders {
        jsURLs := extractJSURLsFromCSP(cspHeader)
        scriptURLs = append(scriptURLs, jsURLs...)
        extractDomainsFromCSP(cspHeader, domains)
    }

    for _, url := range scriptURLs {
        wg.Add(1)
        go func(url string) {
            defer wg.Done()
            fmt.Printf("Fetching JS: %s\n", url)
            if ds, err := fetchAndParseJS(url); err == nil {
                for _, d := range ds {
                    domains[d] = struct{}{}
                }
            }
        }(url)
    }

    wg.Wait()

    fmt.Println("\nDetected the following domains from CSP and Referenced JS:")
    for domain := range domains {
        fmt.Println(domain)
    }
}

func fetchAndParseJS(url string) ([]string, error) {
    resp, err := http.Get(url)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        return nil, err
    }

    return parseDomains(string(body)), nil
}

func parseDomains(js string) []string {
    domainRegex := regexp.MustCompile(`https?://[^\s/"'<>]+`)
    matches := domainRegex.FindAllString(js, -1)

    seen := make(map[string]struct{})
    var domains []string
    for _, match := range matches {
        if _, exists := seen[match]; !exists {
            seen[match] = struct{}{}
            domains = append(domains, match)
        }
    }
    return domains
}

func extractDomainsFromCSP(csp string, domains map[string]struct{}) {
    domainRegex := regexp.MustCompile(`https?://[^\s/"'<>]+`)
    matches := domainRegex.FindAllString(csp, -1)
    for _, match := range matches {
        domains[match] = struct{}{}
    }
}

func extractJSURLsFromCSP(cspHeader string) []string {
    jsURLRegex := regexp.MustCompile(`https?://[^\s/"'<>]+\.js`)
    return jsURLRegex.FindAllString(cspHeader, -1)
}