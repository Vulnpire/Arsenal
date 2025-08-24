package main

import (
        "bufio"
        "fmt"
        "os"
        "os/exec"
        "os/signal"
        "regexp"
        "strings"
        "sync"
        "syscall"
)

func main() {
        // Ensure axiom-scan is installed
        if _, err := exec.LookPath("axiom-scan"); err != nil {
                fmt.Println("Error: axiom-scan is not installed or not in PATH.")
                os.Exit(1)
        }

        if len(os.Args) < 3 || os.Args[1] != "-m" {
                fmt.Println("Usage: cat input | axs -m <module> [other flags]")
                os.Exit(1)
        }

        module := os.Args[2]
        args := append([]string{"-m", module}, os.Args[3:]...)

        // Create temp input file
        tempFile, err := os.CreateTemp("", "axs_input_*.txt")
        if err != nil {
                fmt.Println("Error: Could not create temp file.")
                os.Exit(1)
        }
        defer os.Remove(tempFile.Name())

        // Read stdin into temp file
        scanner := bufio.NewScanner(os.Stdin)
        for scanner.Scan() {
                fmt.Fprintln(tempFile, scanner.Text())
        }
        tempFile.Close()

        // Prepare axiom-scan command
        cmd := exec.Command("axiom-scan", append([]string{tempFile.Name(), "--rm-logs"}, args...)...)

        // Pipe stdout/stderr
        stdout, _ := cmd.StdoutPipe()
        stderr, _ := cmd.StderrPipe()

        var waitOnce sync.Once
        sigChan := make(chan os.Signal, 1)
        signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
        go func() {
                <-sigChan
                fmt.Println("\n[!] CTRL+C detected. Waiting for axiom-scan to exit...")
                if cmd.Process != nil {
                        waitOnce.Do(func() { cmd.Wait() })
                }
                os.Remove(tempFile.Name())
                os.Exit(0)
        }()

        err = cmd.Start()
        if err != nil {
                fmt.Println("Error: Failed to start axiom-scan:", err)
                os.Exit(1)
        }

        // Combine stdout & stderr for live output
        outScanner := bufio.NewScanner(stdout)
        errScanner := bufio.NewScanner(stderr)

        pathPattern := regexp.MustCompile(`==> /(home|root)/.*`)
        const skipFirst = 18
        const skipLast = 11
        lineCount := 0
        buffer := make([]string, 0, skipLast+1)

        printLine := func(line string) {
                // Remove paths
                line = pathPattern.ReplaceAllString(line, "")
                if strings.TrimSpace(line) == "" {
                        return
                }

                buffer = append(buffer, line)
                if len(buffer) > skipLast {
                        fmt.Println(buffer[0])
                        buffer = buffer[1:]
                }
        }

        go func() {
                for outScanner.Scan() {
                        if lineCount < skipFirst {
                                lineCount++
                                continue
                        }
                        printLine(outScanner.Text())
                }
        }()
        go func() {
                for errScanner.Scan() {
                        if lineCount < skipFirst {
                                lineCount++
                                continue
                        }
                        printLine(errScanner.Text())
                }
        }()

        waitOnce.Do(func() { cmd.Wait() })
}
