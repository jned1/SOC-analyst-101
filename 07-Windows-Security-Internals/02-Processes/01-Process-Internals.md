# 01-Process-Internals.md

## Overview

### What a Process Is in Windows

A process in Windows is a kernel-managed execution container that encapsulates:

- A virtual address space
- One or more threads
- A security context (access token)
- System resources such as handles and objects

It is represented internally by kernel data structures and enforced by the Windows Executive.

A process is not just running code. It is a structured, security-bound execution environment.

---

### Difference Between a Process and a Program

A program is a file on disk (e.g., an executable image).

A process is a runtime instance of that program in memory.

One program can create multiple processes. Each process:

- Has its own memory space
- Has its own PID
- Maintains its own access token

Security analysis focuses on processes, not programs, because attacks operate at runtime.

---

### Why Process Internals Matter for Security Analysis

Most endpoint attacks manipulate:

- Process memory
- Access tokens
- Parent-child relationships
- Handles
- Threads

Understanding how Windows structures a process enables accurate detection of:

- Privilege escalation
- Process injection
- Credential access
- Evasion techniques

---

## Process Structure in Windows

### EPROCESS Structure (High-Level Explanation)

Internally, each process is represented in kernel memory by an EPROCESS structure.

EPROCESS contains:

- Process ID
- Active process links
- Pointer to access token
- Pointer to address space (via KPROCESS)
- Handle table reference
- Image file name
- Security flags

This structure exists only in kernel memory and cannot be directly modified from user mode without exploitation.

---

### Kernel Object Representation

A process is a kernel object managed by the Object Manager.

It has:

- A security descriptor
- A reference count
- Access control enforcement

Processes are referenced via handles with specific access rights.

---

### Relationship with Threads

A process contains one or more threads.

Threads:

- Execute instructions
- Share the process address space
- Share the same access token (unless impersonating)

Without threads, a process cannot execute code.

Attackers often inject malicious threads into legitimate processes.

---

### Relationship with Access Tokens

Each process has a primary access token.

The token defines:

- User identity
- Group membership
- Privileges
- Integrity level

The EPROCESS structure maintains a pointer to this token.

Token manipulation is central to privilege escalation.

---

## Process Memory Layout

### Virtual Address Space

Each process receives its own isolated virtual address space.

On x64 systems:

- User-mode portion
- Kernel-mode portion (shared, not directly accessible)

Memory isolation prevents direct cross-process memory access without appropriate rights.

---

### Image Section (Executable)

The executable file is mapped into memory as an image section.

It contains:

- Code (.text)
- Read-only data
- Import table
- Export table

Process hollowing targets this region.

---

### Heap

The heap stores dynamically allocated memory.

Common abuse:

- Shellcode placement
- Reflective DLL loading
- Payload staging

Heap spraying techniques historically targeted memory corruption.

---

### Stack

Each thread has its own stack.

The stack contains:

- Function parameters
- Return addresses
- Local variables

Stack manipulation may occur during exploitation.

---

### Loaded Modules (DLLs)

DLLs are mapped into the process address space.

They provide:

- Shared functionality
- Imported APIs
- Runtime libraries

Module enumeration is essential during incident response.

---

## Process Identifiers

### Process ID (PID)

Each process has a unique identifier during its lifetime.

PID is used by:

- Logging systems
- EDR tools
- Task managers

PID reuse can complicate forensic timelines.

---

### Parent Process ID (PPID)

The PPID identifies the process that created the current process.

Parent-child relationships form process trees.

---

### Why Parent-Child Relationships Matter

Attack detection relies heavily on process lineage.

Examples of suspicious patterns:

- Office application spawning PowerShell
- Browser spawning cmd.exe
- Service process spawning interactive shells

Parent process spoofing attempts to manipulate this trust model.

---

## Process Security Context

### Access Tokens

The access token contains:

- User SID
- Group SIDs
- Privileges
- Integrity level

It determines what the process is allowed to do.

---

### Security Identifiers (SIDs)

SIDs uniquely identify:

- Users
- Groups
- System accounts

Access decisions compare SIDs in the token against object security descriptors.

---

### Privileges

Privileges enable sensitive operations such as:

- SeDebugPrivilege
- SeImpersonatePrivilege
- SeAssignPrimaryTokenPrivilege

Attackers frequently escalate by enabling or abusing these privileges.

---

### Integrity Levels

Integrity levels enforce mandatory access control:

- Low
- Medium
- High
- System

A low-integrity process cannot modify higher-integrity objects.

Integrity bypass may indicate exploitation.

---

## Handles and Object Access

### Handle Table

Each process maintains a handle table.

Handles reference kernel objects:

- Files
- Processes
- Threads
- Tokens
- Registry keys

Each handle includes specific access rights.

---

### Access Rights

Common process rights:

- PROCESS_VM_READ
- PROCESS_VM_WRITE
- PROCESS_CREATE_THREAD
- PROCESS_DUP_HANDLE

Overly permissive handle access enables injection.

---

### Why Handle Duplication Is Dangerous

If a low-privilege process duplicates a high-privilege handle:

- It may gain unintended access
- It can interact with privileged processes

Handle inheritance and duplication are common privilege escalation vectors.

---

## Process Creation and Termination (High-Level)

### Role of CreateProcess

CreateProcess():

- Creates a new process object
- Allocates address space
- Initializes EPROCESS
- Assigns access token
- Creates initial thread

This involves both user-mode and kernel-mode components.

---

### Kernel Involvement

Kernel responsibilities:

- Allocating EPROCESS structure
- Setting up virtual memory
- Linking process into active list
- Applying security descriptors

Process creation is not purely user-mode.

---

### Cleanup and Resource Release

On termination:

- Threads are terminated
- Handles are closed
- Memory is released
- Kernel references are decremented

Improper cleanup may leave forensic artifacts.

---

## Security Implications

### Process Injection Concepts

Injection techniques include:

- Remote thread creation
- APC injection
- Section mapping
- DLL injection

They require access rights to another process object.

---

### Token Theft

Attackers with kernel access or specific privileges may:

- Replace process token pointer
- Duplicate SYSTEM tokens
- Impersonate higher-privilege users

Token theft results in immediate privilege escalation.

---

### Parent Process Spoofing

Attackers may:

- Manipulate process creation attributes
- Forge PPID relationships

This disrupts detection logic based on process trees.

---

### Hollowing (Conceptual Only)

Process hollowing involves:

1. Creating a legitimate process in suspended state
2. Replacing its image section
3. Resuming execution

The process appears legitimate but runs malicious code.

---

### Abusing Handles for Privilege Escalation

If a process obtains:

    PROCESS_ALL_ACCESS

To a privileged process, it may:

- Inject code
- Read memory
- Manipulate execution

Handle misuse frequently appears in post-exploitation chains.

---

## Defensive and SOC Perspective

### Why Process Tree Analysis Is Critical

Process trees reveal:

- Initial infection vectors
- Execution chains
- Lateral movement paths

Lineage analysis often exposes malicious pivots.

---

### Indicators of Abnormal Parent-Child Relationships

Suspicious indicators include:

- System processes spawning user applications
- Office applications spawning scripting engines
- Services spawning interactive shells

Contextual baselining is essential.

---

### Detecting Suspicious Handle Access

Monitor:

- Requests for PROCESS_VM_WRITE
- Requests for PROCESS_CREATE_THREAD
- Token handle duplication

Unexpected cross-process access is high risk.

---

### Monitoring Abnormal Token Privileges

Alert when:

- Non-administrative users gain SeDebugPrivilege
- Tokens suddenly escalate integrity
- Service accounts perform interactive actions

Token anomalies often precede privilege escalation.

---

### Correlating Process Behavior with Logs

Effective investigation requires correlation of:

- Process creation logs
- Token privilege changes
- Network connections
- File writes
- Registry modifications

Single-event analysis is insufficient.

---

## Key Takeaways

- A process is a structured security container managed by the kernel.
- EPROCESS, access tokens, and handle tables define its security posture.
- Most endpoint attacks manipulate process internals.
- Injection, token theft, and hollowing exploit process architecture.
- Parent-child relationships are central to detection workflows.
- Deep process understanding improves privilege escalation analysis, credential theft detection, and incident response accuracy.

Mastery of Windows process internals enables defenders to understand how attackers pivot, escalate, inject, and persist within enterprise environments. Process architecture is the foundation of modern endpoint attack detection.