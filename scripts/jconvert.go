package main

import (
    "bufio"
    "encoding/json"
    "fmt"
    "os"
)

func main() {
    var lines []string

    scanner := bufio.NewScanner(os.Stdin)
    for scanner.Scan() {
        lines = append(lines, scanner.Text())
    }

    if err := scanner.Err(); err != nil {
        fmt.Fprintln(os.Stderr, "Error reading input:", err)
        os.Exit(1)
    }

    // convert to JSON
    jsonData, err := json.MarshalIndent(lines, "", "  ")
    if err != nil {
        fmt.Fprintln(os.Stderr, "Error converting to JSON:", err)
        os.Exit(1)
    }

    fmt.Println(string(jsonData))
}
