# 06 - Handles

## Overview

In Windows, a *handle* is an abstract reference that a user-mode application uses to interact with an internal system resource. These resources are implemented in the Windows kernel as **kernel objects**, which represent fundamental operating system components such as processes, threads, files, registry keys, synchronization primitives, and memory sections.

Applications do not interact with kernel objects directly. Instead, Windows provides **handles as an intermediary layer** that allows controlled access to these objects.

This design provides several advantages:

- Enforces security boundaries between processes
- Allows the kernel to control access to sensitive resources
- Enables reference tracking and resource lifetime management
- Prevents direct user-mode interaction with kernel memory structures

Handles therefore play a central role in **Windows resource management and system security**.

From a defensive and SOC perspective, handle usage is also important because many attack techniques rely on **obtaining or abusing handles to other processes or system objects**.

---

## What a Handle Is in Windows

A **handle** is a process-specific identifier that represents a reference to a kernel object.

When an application opens or creates a resource, the Windows kernel creates a handle entry in the process's **handle table** and returns a small integer value to the application. This value is used in subsequent API calls to operate on the object.

Example conceptual flow:

    Application
        |
        | CreateFile()
        v
    Windows API
        |
        v
    Kernel creates file object
        |
        v
    Kernel returns HANDLE value

The handle itself does not contain the object. Instead, it is an **index into a handle table entry** maintained by the kernel.

Important characteristics of handles:

- Handles are **valid only within the process that owns them**
- Handles contain **access rights information**
- Handles reference **kernel objects managed by the Object Manager**
- Handles allow the kernel to track object usage and lifetime

---

## Why Handles Exist Between Applications and Kernel Objects

Handles act as a **security and abstraction layer** between user applications and the Windows kernel.

Without handles, applications would need direct pointers to kernel memory structures, which would create severe security and stability risks.

Handles solve this problem by providing:

### Abstraction

Applications do not need to know the internal structure of kernel objects.

### Access Control

Each handle contains an **access mask** defining what operations are allowed.

### Isolation

Handles exist inside a **per-process handle table**, preventing unauthorized access by other processes.

### Resource Tracking

The kernel can monitor references to objects and automatically release them when they are no longer needed.

This model ensures that **applications interact with system resources safely and predictably**.

---

## The Role of Handles in Windows Resource Management

Handles allow Windows to maintain precise control over resource usage.

When a process opens a resource:

1. The kernel creates or locates the corresponding kernel object.
2. A handle entry is added to the process handle table.
3. Access rights are assigned to that handle.
4. A reference count on the object is incremented.

When the handle is closed:

1. The handle table entry is removed.
2. The object's reference count is decremented.
3. If the reference count reaches zero, the object is destroyed.

This system prevents:

- Resource leaks
- Premature object destruction
- Unauthorized access to system resources

---

## Windows Object Manager and Kernel Objects

### The Windows Object Manager

The **Object Manager** is a core Windows kernel component responsible for managing all kernel objects.

Its responsibilities include:

- Creating kernel objects
- Managing object namespaces
- Maintaining object reference counts
- Enforcing security descriptors
- Managing handles and handle tables

Every kernel object in Windows is managed through this subsystem.

---

### What Kernel Objects Are

Kernel objects represent internal operating system structures that encapsulate system resources or functionality.

Examples include:

- Processes
- Threads
- Files
- Registry keys
- Events
- Mutexes
- Semaphores
- Sections (shared memory)
- Access tokens

These objects reside in **kernel memory** and cannot be accessed directly by user applications.

---

### Relationship Between Objects and Handles

A **kernel object** represents the actual system resource.

A **handle** is a reference to that object stored in a process handle table.

Multiple handles may reference the same object.

Example:

    Kernel Object (Process)
        ^
        | reference
    Handle A (Process 1)
        |
    Handle B (Process 2)

Each handle may have **different access rights**, even though they reference the same underlying object.

---

## Handle Tables

### Per-Process Handle Tables

Every process in Windows maintains its own **handle table**.

This table maps handle values to kernel object references.

Structure conceptually:

    Process
        |
        v
    Handle Table
        |
        +-- Handle 0x50 → File Object
        +-- Handle 0x64 → Process Object
        +-- Handle 0x70 → Registry Key Object

This design enforces **process isolation**, because one process cannot directly access another process's handles.

---

### Handle Values and Object References

The handle value returned to applications is simply an identifier.

Internally, the handle table entry contains:

- Pointer to the kernel object
- Access rights mask
- Reference information
- Handle attributes

The kernel resolves the handle value to the corresponding object during system calls.

---

### Reference Counting and Object Lifetime

Kernel objects maintain a **reference count**.

Every handle referencing the object increases the count.

Example lifecycle:

    Object created → reference count = 1
    Second handle opened → reference count = 2
    One handle closed → reference count = 1
    Last handle closed → reference count = 0 → object destroyed

This mechanism ensures that objects remain valid as long as they are in use.

---

## Handle Creation

Handles are typically created through Windows API functions that interact with system resources.

These APIs request the kernel to create or open an object and return a handle.

Common examples include:

### CreateFile

Creates or opens a file object and returns a file handle.

Conceptual flow:

    Application → CreateFile()
                 → Kernel creates file object
                 → Handle returned

---

### OpenProcess

Returns a handle to another process object.

Used by:

- debuggers
- monitoring tools
- administrative utilities
- attackers attempting process manipulation

---

### OpenThread

Returns a handle to a thread object.

This allows operations such as suspending or inspecting a thread.

---

### RegOpenKey

Opens a registry key and returns a handle to the registry object.

This allows reading or modifying registry values.

---

## Handle Access Rights

When a handle is created, it is assigned an **access mask** describing what operations are permitted.

The access mask is critical for enforcing security.

---

### Access Masks

An access mask is a set of flags defining allowed operations on the object.

Example concept:

    Access Mask = READ | WRITE | EXECUTE

If a process attempts an operation not permitted by the mask, the kernel denies the request.

---

### Process Access Rights

For process objects, specific rights exist.

Examples include:

PROCESS_VM_READ  
Allows reading memory from the process.

PROCESS_VM_WRITE  
Allows writing memory into the process.

PROCESS_VM_OPERATION  
Allows performing memory operations.

PROCESS_CREATE_THREAD  
Allows creating a thread inside the process.

PROCESS_TERMINATE  
Allows terminating the process.

These permissions are extremely sensitive.

---

### Why Access Rights Matter for Security

Access rights control **what a process is allowed to do to another object**.

If a process obtains excessive rights to another process, it may be able to:

- read memory
- modify memory
- create remote threads
- terminate the process

These capabilities are frequently abused by malware.

---

## Handle Inheritance and Duplication

Handles can be shared between processes.

This happens primarily through **inheritance** or **duplication**.

---

### Handle Inheritance During Process Creation

When a process creates a child process, certain handles may be marked as **inheritable**.

If inheritance is enabled, the child process receives copies of those handles.

Example:

    Parent Process
        |
        | CreateProcess()
        v
    Child Process inherits handles

This feature is useful for legitimate inter-process communication but must be controlled carefully.

---

### DuplicateHandle Mechanism

Windows provides the `DuplicateHandle` function, which allows one process to create a handle to an object owned by another process.

Conceptually:

    Process A → duplicate handle → Process B

This allows controlled sharing of system resources.

However, if abused, it can allow unauthorized processes to gain access to sensitive objects.

---

## Security Implications of Handles

Handles are a common target for attackers because they represent **authorized access paths to protected objects**.

Several attack techniques rely on handle misuse.

---

### Unauthorized Process Access

If an attacker obtains a handle to a privileged process with excessive rights, they may manipulate it.

Examples include:

- modifying memory
- injecting code
- terminating security software

---

### Token Theft via Handle Access

Processes hold **access tokens** representing user privileges.

If an attacker gains a handle with sufficient rights to a process belonging to a privileged user, they may duplicate or steal the token.

This can lead to **privilege escalation**.

---

### Privilege Escalation Through Excessive Handle Rights

Poorly configured services may expose handles with overly permissive access rights.

Attackers can exploit these handles to perform operations that should normally require elevated privileges.

---

### Handle Leaks and Security Impact

A **handle leak** occurs when a program fails to close handles.

Security consequences may include:

- resource exhaustion
- denial of service
- unintended persistent access to sensitive objects

---

## Handles and Process Injection

Many Windows attack techniques depend on obtaining handles to another process.

Process injection is a prime example.

---

### Required Access Rights

To inject code into another process, attackers typically require:

PROCESS_VM_WRITE  
Allows writing malicious code into the target process memory.

PROCESS_VM_OPERATION  
Allows allocating memory.

PROCESS_CREATE_THREAD  
Allows executing the injected code.

---

### How Handles Enable Memory Manipulation

Typical injection flow:

    OpenProcess(target_process)
        |
        v
    VirtualAllocEx(target)
        |
        v
    WriteProcessMemory(target)
        |
        v
    CreateRemoteThread(target)

Each step relies on a **handle to the target process**.

Without that handle, the kernel would deny the operation.

---

## SOC and Detection Perspective

From a defensive standpoint, monitoring handle usage can reveal malicious behavior.

Attackers often interact with processes in ways that normal applications do not.

---

### Monitoring Suspicious Process Access

Security monitoring tools may track calls such as:

    OpenProcess
    DuplicateHandle

Particularly when targeting sensitive processes like:

- authentication services
- security tools
- system processes

---

### Detecting Abnormal Handle Rights Requests

Requests for rights such as:

PROCESS_VM_WRITE  
PROCESS_CREATE_THREAD  
PROCESS_ALL_ACCESS  

can indicate suspicious activity.

These rights are commonly required for:

- code injection
- credential dumping
- process manipulation

---

### Observing Handle Enumeration Tools

Attack tools frequently enumerate system handles to discover targets.

Utilities and malware may inspect handle tables to locate:

- privileged processes
- token objects
- sensitive resources

---

### Relationship to Credential Dumping and Injection

Credential dumping tools often obtain handles to the **Local Security Authority process** in order to read authentication data from memory.

Similarly, malware performing process injection must first obtain a handle with sufficient rights.

Therefore, **handle acquisition is often the first step in an attack chain**.

---

## Key Takeaways

Handles are controlled references to kernel objects that allow user applications to interact with internal Windows resources.

They exist as a secure abstraction layer between applications and kernel objects, allowing Windows to enforce access control and resource management.

Access rights embedded in handles determine what operations a process can perform on an object.

From a security perspective, handle misuse is a common technique in Windows attacks.

Many offensive techniques rely on obtaining powerful handles to other processes in order to:

- read or modify memory
- inject code
- steal security tokens
- manipulate system resources

For defenders and SOC analysts, understanding handle behavior is essential for detecting malicious activity related to:

- process injection
- privilege escalation
- credential dumping

Windows handle architecture therefore represents a critical component of both **system functionality and security monitoring**.