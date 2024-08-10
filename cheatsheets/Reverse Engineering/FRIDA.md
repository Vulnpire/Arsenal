# FRIDA

## Table of Contents
1. [Getting Started](#getting-started)
2. [Basic Commands](#basic-commands)
3. [Attaching to a Process](#attaching-to-a-process)
4. [Scripting with Frida](#scripting-with-frida)
5. [Inspecting and Manipulating Memory](#inspecting-and-manipulating-memory)
6. [Interacting with Functions](#interacting-with-functions)
7. [Working with Interceptors](#working-with-interceptors)
8. [Handling Exceptions](#handling-exceptions)
9. [Frida Tools](#frida-tools)
10. [Common Frida Commands](#common-frida-commands)

---

## Getting Started

- **Install Frida**:  

> pip install frida-tools

- **Check Frida Version**:  

> frida --version

- **Start Frida Server on Android**:  

adb shell "su -c '/data/local/tmp/frida-server &'"

## Basic Commands

List All Devices:

> frida-ls-devices

List All Running Applications:

> frida-ps -U

Spawn a New Process:

> frida -U -f <app_name> --no-pause

Attach to a Running Process:

> frida -U -n <app_name>

Kill a Running Process:

> frida-kill -U <app_name>

## Attaching to a Process

Attach to a Process by Name:

> frida -n <process_name>

Attach to a Process by PID:

> frida -p <pid>

Attach to a Process on a Remote Device:

> frida -U -n <process_name>

Detach from a Process:

> detach()

## Scripting with Frida

* Load a Script:

```
const script = await session.createScript(`
    console.log('0xD34db33f1337');
`);
await script.load();
```

Message Handling in Scripts:

```
script.message.connect(message => {
    console.log(message);
});
```

Calling Native Functions:

```const open = new NativeFunction(Module.getExportByName(null, 'open'), 'int', ['pointer', 'int']);```

Enumerate Loaded Modules:

```
Process.enumerateModules({
    onMatch: function(module) {
        console.log(module.name);
    },
    onComplete: function() {
        console.log('Done');
    }
});
```

## Inspecting and Manipulating Memory

Read Memory at an Address:

```
const address = ptr('0x12345678');
const data = Memory.readByteArray(address, 64);
```

Write Memory at an Address:

```Memory.writeUtf8String(ptr('0x12345678'), 'Hello, World!');```

Search for a Specific Pattern in Memory:

```
Memory.scan(ptr('0x10000000'), 0x1000, '41 42 43 44', {
    onMatch: function(address, size) {
        console.log('Found at:', address);
    },
    onComplete: function() {
        console.log('Scan complete');
    }
});
```

## Interacting with Functions

Hook a Function:

```
Interceptor.attach(ptr('0x12345678'), {
    onEnter: function(args) {
        console.log('Function called with arguments:', args[0]);
    },
    onLeave: function(retval) {
        console.log('Function returned:', retval);
    }
});
```

Replace a Function Implementation:

```
Interceptor.replace(ptr('0x12345678'), new NativeCallback(function() {
    return 42;
}, 'int', []));
```

## Working with Interceptors

Attach an Interceptor:

```
Interceptor.attach(Module.findExportByName(null, 'open'), {
    onEnter: function(args) {
        console.log('open called with:', Memory.readUtf8String(args[0]));
    },
    onLeave: function(retval) {
        console.log('open returned:', retval);
    }
});
```

Detach an Interceptor:

> detach()

## Handling Exceptions

Catch and Handle Exceptions:

```
try {
    const data = Memory.readUtf8String(ptr('0x12345678'));
} catch (e) {
    console.log('Exception caught:', e.message);
}
```

Force an Exception:

```throw new Error('This is a forced exception');```

Frida Tools

Frida Trace:

> frida-trace -U -p <pid> -i "open"

Frida Dump:

> frida-dump -U <app_name>

Frida CLI:

> frida -U -n <app_name>

Common Frida Commands

Command	                          Description
- `frida -n <process_name>`	      Attach to a process by name.
- `frida -p <pid>`	              Attach to a process by PID.
- `Interceptor.attach()`	        Hook into a function.
- `Memory.readUtf8String()`	      Read a UTF-8 string from memory.
- `Memory.writeUtf8String()`	    Write a UTF-8 string to memory.
- `frida-trace -U -p <pid>`	      Trace function calls in a running process.
- `Process.enumerateModules()`	  Enumerate all loaded modules in the process.
- `Interceptor.replace()`	        Replace a function's implementation.
- `detach()`	                    Detach from the current session.
- `frida -U -n <app_name>`	      Common Frida Commands
