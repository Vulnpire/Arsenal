# Radare2 (r2) Cheatsheet

**Note**: This is my first cheatsheet, so there might be some mistakes. If you spot any errors or have suggestions for improvement, feel free to share them!

## Table of Contents
1. [Getting Started](#getting-started)
2. [Running and Stopping the Program](#running-and-stopping-the-program)
3. [Breakpoints](#breakpoints)
4. [Examining the Program](#examining-the-program)
5. [Working with Variables](#working-with-variables)
6. [Controlling Execution](#controlling-execution)
7. [Stack Management](#stack-management)
8. [Signals](#signals)
9. [Advanced Features](#advanced-features)
10. [Radare2 Scripting](#radare2-scripting)
11. [Common Radare2 Commands](#common-radare2-commands)

---

## Getting Started

- **Starting Radare2**:  

> r2 <program>

- **Open a File without Analysis**:  

> r2 -nn <file>

- **Load a Program in Debug Mode**:  

> r2 -d <program>

- **Load a Core Dump**:  

> r2 -c <core>

## Running and Stopping the Program

- **Run the Program**:  

> dc

- **Step Into (Next Instruction)**:  

> ds

- **Continue Execution Until a Breakpoint or Crash**:  

> dc

- **Restart the Program**:  

> ood

- **Quit Radare2**:  

> q

## Breakpoints

- **Set a Breakpoint**:  

> db <address>

- **Set a Breakpoint by Function Name**:  

> db <function>

- **Delete a Breakpoint**:  

> db- <address>

- **List All Breakpoints**:  

> db

- **Enable/Disable a Breakpoint**:  

> db <address> / dbd <address>

## Examining the Program

- **Analyze All Functions and Symbols**:  

> aaa

- **Analyze a Single Function**:  

> af <address>

- **Print the Disassembly of the Current Function**:  

> pdf

- **Print Hex Dump of Memory**:  

> px <length> @ <address>

- **View Registers**:  

> dr

- **Backtrace (Call Stack)**:  

> drr

## Working with Variables

- **View Local Variables**:  

> afvd

- **Set a Register Value**:  

> dr <register>=<value>

- **Watch a Variable**:  

> dzw <size> @ <address>

- **List Watchpoints**:  

> dzw

- **Remove a Watchpoint**:  

> dzw- <address>

## Controlling Execution

- **Step Over (Next Instruction, Skip Call)**:  

> dso

- **Step Out (Finish Function)**:  

> dro

- **Jump to Specific Address**:  

> s <address>

- **Seek to Main Function**:  

> s main

- **Print Function Arguments**:  

> afva

## Stack Management

- **Print the Stack**:  

> pxr @ sp

- **Examine the Current Stack Frame**:  

> afi

- **Change Stack Frame**:  

> s <address>

- **Return from Function**:  

> aeim

## Signals

- **Handle a Signal**:  

> dsh <signal>

- **Send a Signal to the Program**:  

> ds <signal>

- **Continue Program After Signal**:  

> dc

## Advanced Features

- **Attach to a Running Process**:  

> r2 -d <pid>

- **Detach from a Process**:  

> ddp

- **Redirect Program Output to a Log File**:  

> > log.txt

- **Define a Command Alias**:  

> e cmd.alias.<alias>=<command>

## Radare2 Scripting

- **Execute a Command Script**:  

> . <file>

- **Save Commands to a File**:  

> wtf <file>

- **Run Commands on Startup**:  

> echo "commands" > ~/.radare2rc

## Common Radare2 Commands

Command	      Description

- `r2 <file>`	      Start Radare2 with the specified file.
- `dc`	      Run/Continue program execution.
- `db <address>`	      Set a breakpoint at the specified address.
- `ds`	      Step into the next instruction.
- `dso`	      Step over the next instruction.
- `pdf`	      Print disassembly of the current function.
- `dr`	      View the current register values.
- `px <length> @ <address>`   Print a hex dump of memory.
- `q`	      Quit Radare2.
