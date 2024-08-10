# GDB Cheatsheet

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
10. [GDB Scripting](#gdb-scripting)
11. [Common GDB Commands](#common-gdb-commands)

---

## Getting Started

- **Starting GDB**:  

> gdb <program>

## Starting GDB with a Core Dump:

> gdb <program> <core>

## Compiling with Debugging Information:

> gcc -g -o <output> <source.c>

## Starting GDB with Arguments:

> gdb --args <program> <args>

## Running and Stopping the Program

Run the Program:

> run [args]

Restart the Program from the Beginning:

> start

Continue Execution After a Break:

> continue

Stop the Program:

> kill

Quit GDB:

> quit

## Breakpoints

Set a Breakpoint:

> break <location>

Set a Conditional Breakpoint:

> break <location> if <condition>

Delete a Breakpoint:

> delete <breakpoint number>

Disable a Breakpoint:

> disable <breakpoint number>

Enable a Breakpoint:

> enable <breakpoint number>

List All Breakpoints:

> info breakpoints

## Examining the Program

Backtrace (Call Stack):

> backtrace

Print the Value of an Expression:

> print <expression>

Examine Memory:

> x/<format> <address>

* <format>: Number and format of items to display (e.g., x/10xw shows 10 words in hex).

List Source Code:

> list <location>

Search Source Code:

> search <regex>

## Working with Variables

Print a Variable:

> print <variable>

Set a Variable:

> set variable <variable>=<value>

Display Variable Value After Each Step:

> display <variable>

Remove a Displayed Variable:

> undisplay <display number>

Watch a Variable (Break When Modified):

> watch <variable>

## Controlling Execution

Step to Next Instruction (Enter Function):

> step

Step to Next Line (Skip Function):

> next

Finish Current Function and Return:

> finish

Jump to Specific Line:

> jump <location>

## Stack Management

View Backtrace (Call Stack):

> backtrace

Change Stack Frame:

> frame <frame number>

Return from Stack Frame:

> return [<expression>]

Print Function Arguments:

> info args

Print Local Variables:

> info locals

## Signals

Catch a Signal:

> handle <signal> [actions]

-- actions: stop, ignore, print.

Send a Signal to the Program:

> signal <signal>

Continue Program on Signal:

> continue

## Advanced Features

Attach to a Running Process:

> attach <pid>

Detach from a Process:

> detach

Redirect Program Output to a Log File:

> set logging on

Define a Command Alias:

> alias <new-command>=<existing-command>

## GDB Scripting

Execute a Command File:

> source <file>

Save Breakpoints to a File:

> save breakpoints <file>

Run Commands on Startup:

> echo "commands" > .gdbinit


###

## Common GDB Commands

Command	    Description

`run`	    Start the program
`start`	    Restart the program from the beginning
`break`	    Set a breakpoint
`continue`	Continue execution
`next`   	Step to the next line
`step`	    Step into a function
`backtrace`	Show the call stack
`print`	    Print a variable or expression
`watch` 	Break when a variable changes
`info`  	Display various information
`quit`  	Quit GDB