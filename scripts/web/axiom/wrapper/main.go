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
)

func main() {
        // Ensure axiom-scan is installed
        _, err := exec.LookPath("axiom-scan")
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

        // Create command
        cmd := exec.Command("axiom-scan", tempFile.Name(), "--rm-logs")
        cmd.Args = append(cmd.Args, args...)

        // Get stdout pipe
        stdout, err := cmd.StdoutPipe()
        if err != nil {
                fmt.Println("Error: Could not capture output.")
                os.Exit(1)
        }

        // Handle SIGINT (CTRL+C) for cleanup
        sigChan := make(chan os.Signal, 1)
        signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
        go func() {
                <-sigChan
                fmt.Println("\n[!] Received termination signal. Cleaning up...")

                // Kill all processes started by this command
                if cmd.Process != nil {
                        _ = cmd.Process.Kill()
                }

                // Ensure all child processes are killed
                _ = exec.Command("pkill", "-P", fmt.Sprint(cmd.Process.Pid)).Run()

                // Remove temporary file
                os.Remove(tempFile.Name())

                os.Exit(1)
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

        // Start the process
        err = cmd.Start()
        if err != nil {
                fmt.Println("Error: Failed to start axiom-scan.")
                os.Exit(1)
        }

        // Stream output while:
        // - Removing first 9 lines
        // - Removing blank lines
        // - Filtering `==> /home/...`
        scanner = bufio.NewScanner(stdout)
        lineCount := 0
        homePathPattern := regexp.MustCompile(`==> /home/.*`)

        for scanner.Scan() {
                line := scanner.Text()

                // Skip first 9 lines (Axiom banner)
                if lineCount < 9 {
                        lineCount++
                        continue
                }

                // Remove `==> /home/...`
                line = homePathPattern.ReplaceAllString(line, "")

                // Remove blank lines
                if strings.TrimSpace(line) == "" {
                        continue
                }

                // Print filtered output
                fmt.Println(line)
        }

        // Wait for process to complete and clean up
        err = cmd.Wait()
        if err != nil {
                fmt.Println("Error: axiom-scan process exited with an error:", err)
        }

        // Ensure cleanup after execution
        os.Remove(tempFile.Name())
}
