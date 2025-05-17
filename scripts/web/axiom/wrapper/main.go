package main

import (
        "bufio"
        "fmt"
        "os"
        "os/exec"
        "os/signal"
        "regexp"
        "strings"
        "syscall"
        "sync"
)

func main() {
        // Select all axiom instances first
        selectCmd := exec.Command("axiom-select", "*")
        selectCmd.Stdout = os.Stdout
        selectCmd.Stderr = os.Stderr
        err := selectCmd.Run()
        if err != nil {
                fmt.Println("Error: Failed to run 'axiom-select \"*\"'")
                os.Exit(1)
        }

        // Ensure axiom-scan is installed
        _, err = exec.LookPath("axiom-scan")
        if err != nil {
                fmt.Println("Error: axiom-scan is not installed or not in PATH.")
                os.Exit(1)
        }

        // Ensure module is provided
        if len(os.Args) < 3 || os.Args[1] != "-m" {
                fmt.Println("Usage: cat input | axs -m <module> [other flags]")
                os.Exit(1)
        }

        module := os.Args[2]
        args := append([]string{"-m", module}, os.Args[3:]...)

        // Create a temp file for storing stdin input
        tempFile, err := os.CreateTemp("", "axs_input_*.txt")
        if err != nil {
                fmt.Println("Error: Could not create temp file.")
                os.Exit(1)
        }
        defer os.Remove(tempFile.Name()) // Ensure cleanup

        // Create the command but do not start it yet
        cmd := exec.Command("axiom-scan", tempFile.Name(), "--rm-logs")
        cmd.Args = append(cmd.Args, args...)

        // Get stdout pipe
        stdout, err := cmd.StdoutPipe()
        if err != nil {
                fmt.Println("Error: Could not capture output.")
                os.Exit(1)
        }

        // Prevent multiple Wait() calls
        var waitOnce sync.Once

        // Handle SIGINT (CTRL+C) for cleanup AFTER axiom-scan exits
        sigChan := make(chan os.Signal, 1)
        signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

        go func() {
                <-sigChan
                fmt.Println("\n[!] CTRL+C detected. Waiting for axiom-scan to exit...")

                if cmd.Process != nil {
                        waitOnce.Do(func() {
                                err := cmd.Wait()
                                if err != nil {
                                        fmt.Println("Error: axiom-scan exited with an error:", err)
                                }
                        })
                }

                os.Remove(tempFile.Name())
                os.Exit(0)
        }()

        // Read from stdin and write to temp file
        scanner := bufio.NewScanner(os.Stdin)
        for scanner.Scan() {
                _, err := tempFile.WriteString(scanner.Text() + "\n")
                if err != nil {
                        fmt.Println("Error writing to temp file.")
                        os.Exit(1)
                }
        }
        tempFile.Close()

        // Start axiom-scan
        err = cmd.Start()
        if err != nil {
                fmt.Println("Error: Failed to start axiom-scan.")
                os.Exit(1)
        }

        // Stream and filter axiom-scan output
        scanner = bufio.NewScanner(stdout)
        lineCount := 0
        pathPattern := regexp.MustCompile(`==> /(home|root)/.*`)

        for scanner.Scan() {
                line := scanner.Text()

                // Skip axiom-scan banner (first 9 lines)
                if lineCount < 9 {
                        lineCount++
                        continue
                }

                // Remove log file path lines
                line = pathPattern.ReplaceAllString(line, "")

                // Skip blank lines
                if strings.TrimSpace(line) == "" {
                        continue
                }

                // Output the clean result
                fmt.Println(line)
        }

        // Wait for axiom-scan to finish
        waitOnce.Do(func() {
                err = cmd.Wait()
                if err != nil {
                        fmt.Println("Error: axiom-scan process exited with an error:", err)
                }
        })

        // Final cleanup
        os.Remove(tempFile.Name())
}
