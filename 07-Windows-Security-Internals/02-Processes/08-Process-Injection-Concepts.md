# 08 - Process Injection Concepts

## Overview

**Process injection** is a technique in which code from one process is executed inside the address space of another process. Instead of launching a separate malicious executable, the attacker places and runs code within an already running process.

In Windows, processes normally operate within isolated virtual memory spaces. However, the operating system provides controlled mechanisms that allow processes to interact with each other when appropriate permissions are granted. These mechanisms exist for legitimate purposes such as debugging, application extensions, and system management.

Attackers and red-team tools exploit these same mechanisms to place malicious code into trusted processes.

From a security perspective, process injection is significant because it allows attackers to:

- Execute malicious code inside legitimate applications
- Blend malicious activity with trusted processes
- Access sensitive resources available to the target process
- Evade basic detection mechanisms

Understanding process injection requires understanding how Windows manages processes, memory, and access control.

---

## What Process Injection Is

Process injection occurs when one process causes code to execute inside another process's memory space.

Instead of running independently, the malicious code becomes part of the target process.

Conceptually, this involves:

    Process A → writes code into → Process B
    Process B → executes the injected code

Once executed, the injected code runs with the identity, privileges, and access rights of the target process.

This can significantly expand the attacker's capabilities.

---

## Why Attackers Inject Code into Other Processes

Attackers use process injection for several strategic reasons.

### Stealth

Running malicious code inside legitimate processes makes detection more difficult. Security monitoring tools may only observe the trusted application name rather than the malicious activity occurring inside it.

### Privilege Advantage

If the target process runs with elevated privileges, injected code inherits those privileges.

### Access to Sensitive Data

Certain processes handle sensitive data such as authentication tokens, credentials, or browser session data. Injecting code into those processes allows attackers to access that information.

### Evasion of Basic Security Controls

Application allow-listing or basic antivirus systems may allow trusted applications to run without restriction. Injection allows attackers to piggyback on those trusted processes.

---

## Why This Technique Is Common in Malware and Red-Team Tools

Process injection is widely used because it leverages legitimate operating system functionality.

Both malware and red-team tools rely on it to simulate or perform advanced attack behavior.

Advantages include:

- Reduced visibility compared to standalone malware
- Ability to hide within trusted processes
- Flexible execution methods
- Access to privileged process resources

Because these techniques rely on legitimate system calls, distinguishing malicious from legitimate activity requires behavioral analysis.

---

## Windows Architecture That Enables Injection

Several architectural features of Windows make process injection possible.

### Virtual Memory Access Between Processes

Each process has its own virtual address space. However, Windows provides APIs that allow a process with the correct permissions to read or write memory belonging to another process.

This capability is necessary for:

- Debuggers
- System monitoring tools
- Application instrumentation

Attackers abuse the same capability to insert malicious code.

---

### Handle-Based Access Control

Access to another process is controlled through **handles**.

A handle is a reference to a kernel object, such as a process object.

When a process requests access to another process, the operating system performs security checks and returns a handle with specific permissions.

Example access rights include:

    PROCESS_VM_READ
    PROCESS_VM_WRITE
    PROCESS_CREATE_THREAD

If a process obtains these permissions, it can interact with the target process's memory and execution.

---

### Access Tokens and Privileges

Every process in Windows runs under a **security token** that represents its identity and privileges.

The access token determines whether a process can open handles to other processes.

Higher-privileged processes can interact with more sensitive system components.

Attackers often attempt to elevate privileges before performing injection into protected processes.

---

### Process and Thread Objects

Windows represents running programs as **process objects** and **thread objects** inside the kernel.

Process injection ultimately manipulates these objects by:

- Writing into process memory
- Creating or modifying threads
- Altering execution flow

These capabilities exist to support legitimate system functionality but can be abused.

---

## Core Injection Primitives

Although there are many injection techniques, most rely on the same fundamental operations.

### Opening a Handle to the Target Process

The first step is obtaining a handle to the target process.

The requesting process must ask the operating system for specific access rights.

Example conceptual request:

    Request handle → target process
    Required permissions → memory access and execution control

If the request passes security checks, a handle is returned.

---

### Allocating Memory Inside Another Process

The attacker allocates memory within the target process's virtual address space.

This memory region will store the injected payload.

Conceptually:

    Allocate memory → target process
    Memory becomes part of → target process address space

---

### Writing Data into Target Memory

The next step is copying the payload into the allocated memory region.

The payload may contain:

- Executable code
- A dynamic library
- A loader stub

Conceptually:

    Write payload → allocated memory region

At this point, the payload exists in memory but has not yet executed.

---

### Executing Code Inside the Target Process

The final step is triggering execution of the payload.

This may occur by:

- Creating a new thread
- Modifying an existing thread
- Scheduling execution through thread mechanisms

Once executed, the payload runs inside the target process.

---

## Common Process Injection Techniques (Conceptual Overview)

Different techniques vary primarily in how execution is triggered.

### DLL Injection

A malicious dynamic link library is loaded into a target process.

Once loaded, the DLL's initialization code executes automatically.

Attackers use this method because DLL loading is common in normal application behavior.

---

### Process Hollowing

A legitimate process is started in a suspended state.

The original executable memory is replaced with malicious code.

The process is then resumed, causing the malicious code to run under the identity of the legitimate program.

---

### Thread Injection

A new thread is created within the target process.

The thread's starting address points to the injected payload.

The operating system schedules the thread, causing the payload to execute.

---

### APC Injection

Windows threads maintain **Asynchronous Procedure Call (APC)** queues.

Attackers can insert a function into the APC queue of a thread.

When the thread enters an alertable state, the queued code executes.

---

### Reflective DLL Injection

Instead of using the normal Windows loader, a DLL is manually mapped into memory.

The injected loader code resolves imports and performs initialization without using standard module loading mechanisms.

This can reduce visibility to some monitoring tools.

---

## Why Attackers Use Process Injection

Attackers use process injection to achieve several operational goals.

### Privilege Escalation

Injecting code into a higher-privileged process allows attackers to inherit elevated capabilities.

---

### Hiding Inside Trusted Processes

Malicious code running inside trusted processes appears less suspicious to monitoring tools.

Examples of commonly targeted processes include:

- System services
- Web browsers
- Authentication services

---

### Evasion of Security Tools

Some detection mechanisms focus on identifying malicious executables.

Injection allows attackers to avoid launching suspicious binaries.

---

### Persistence and Lateral Movement

Injected code may establish persistence mechanisms or interact with remote systems from a trusted process.

This can help attackers move through a network environment without raising immediate alerts.

---

## Security Implications

Process injection introduces serious security risks.

### Execution Inside Trusted Applications

Malicious code running within legitimate processes can bypass simple security controls.

---

### Memory-Only Malware

Some malware exists only in memory and does not write files to disk.

Process injection is often used to achieve fileless execution.

---

### Bypassing Application Allow-Listing

Application allow-listing policies may allow trusted applications to run.

Injected code executes within those trusted applications.

---

### Blending Malicious Activity with Legitimate Processes

When malicious code executes inside a legitimate process, network traffic, system calls, and file activity may appear normal.

This complicates incident investigation.

---

## Detection and Defensive Perspective (SOC Focus)

Detecting process injection requires behavioral monitoring.

### Suspicious Process Memory Access

Security tools monitor when processes request memory access to other processes.

Unusual requests may indicate preparation for injection.

Examples include:

    PROCESS_VM_WRITE
    PROCESS_VM_OPERATION

---

### Abnormal Handle Requests

Requests for high-risk access rights may indicate malicious activity.

Example pattern:

    OpenProcess → high privileges
    Write memory → target process

---

### Unusual Thread Creation

Creating threads inside another process is a strong indicator of potential injection activity.

Security systems often monitor for:

    Remote thread creation

---

### Monitoring Memory Permission Changes

Executable memory regions that were previously writable may indicate code injection activity.

Monitoring transitions such as:

    Read/Write → Execute

can reveal suspicious behavior.

---

### Relevant Logging Sources

Security monitoring tools rely on event logging to detect injection activity.

Important sources include:

- Process creation logs
- Memory access monitoring
- Sysmon process access events
- Thread creation events

Correlating multiple events often reveals injection patterns.

---

## Key Takeaways

Process injection is a technique that allows code to execute inside another process.

This technique relies entirely on legitimate Windows mechanisms including process handles, virtual memory management, and thread execution.

Most injection techniques use the same core primitives:

    Open process
    Allocate memory
    Write payload
    Execute payload

From a defensive perspective, process injection is dangerous because it allows attackers to hide malicious code inside trusted applications.

SOC analysts must understand how Windows processes interact with each other in order to detect suspicious behaviors such as abnormal handle access, memory manipulation, and remote thread creation.

A strong understanding of Windows process architecture is essential for identifying advanced malware techniques and performing effective incident response.