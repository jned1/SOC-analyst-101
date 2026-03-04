# 03-Process-Creation-Flow.md

## Overview

### What Process Creation Means in Windows

Process creation in Windows is the controlled sequence of user-mode and kernel-mode operations that result in a new executable instance running within its own isolated virtual address space, associated with a security context and one or more threads.

It is not a simple file execution. It is a structured kernel-mediated operation involving:

- Object creation
- Security validation
- Memory management
- Token assignment
- Thread initialization

### Why Understanding Process Creation Is Critical for Security Analysis

Nearly every endpoint attack results in one or more new processes being created.

Understanding the internals of process creation allows analysts to:

- Detect privilege escalation
- Identify token misuse
- Correlate parent-child chains accurately
- Recognize process hollowing timing
- Investigate suspicious execution patterns

Process creation is one of the most observable and security-relevant events in Windows.

---

## High-Level Process Creation Flow

### 1. User-Mode API Call (CreateProcess)

Execution begins in user mode with:

    CreateProcess()

This Win32 API prepares parameters such as:

- Image path
- Command line
- Security attributes
- Creation flags
- Environment block

CreateProcess ultimately calls lower-level Native APIs.

---

### 2. Transition to Native API (NtCreateUserProcess)

The Win32 layer invokes:

    NtCreateUserProcess()

This function resides in:

    ntdll.dll

It prepares the transition from user mode to kernel mode.

---

### 3. System Call Transition to Kernel Mode

NtCreateUserProcess triggers a system call instruction.

The processor switches from user mode (Ring 3) to kernel mode (Ring 0), transferring control to:

    ntoskrnl.exe

This boundary crossing is enforced by the CPU.

---

### 4. Executive Process Object Creation

Inside the kernel:

- The Process Manager creates an EPROCESS structure.
- The Object Manager allocates a process object.
- A unique Process ID (PID) is assigned.
- The process is inserted into the active process list.

This is the authoritative creation point of the process.

---

### 5. Security Reference Monitor (Access Checks)

The Security Reference Monitor (SRM) performs access validation:

- Verifies caller has rights to create the process.
- Validates access to the executable file.
- Applies object security descriptors.

If checks fail, process creation is denied.

---

### 6. Token Assignment

The new process receives a primary access token.

Token source depends on:

- Inherited parent token
- Explicitly supplied token (e.g., CreateProcessAsUser)
- Impersonation context

This token defines:

- User identity
- Privileges
- Integrity level

Token assignment determines the security posture of the new process.

---

### 7. Address Space Creation

The Memory Manager:

- Creates a new virtual address space
- Establishes page tables
- Maps required kernel structures
- Reserves user-mode address range

The address space is isolated from other processes.

---

### 8. Thread Creation

An initial thread is created.

The kernel initializes:

- ETHREAD structure
- TEB (Thread Environment Block)
- Stack allocation

Without a thread, the process cannot execute.

---

### 9. Image Loading

The executable image is mapped into memory as a section object.

The loader:

- Parses PE headers
- Maps code and data sections
- Resolves imports
- Applies relocations
- Initializes PEB fields

At this stage, the process image becomes executable.

---

### 10. Initial Thread Start

The initial thread begins execution at the image entry point.

Control transitions back to user mode.

The process is now running.

---

## Components Involved

### Win32 Subsystem

Provides the CreateProcess interface and parameter translation.

It abstracts Native API complexity from applications.

---

### ntdll.dll

Contains Native APIs such as:

    NtCreateUserProcess

It performs the system call transition to kernel mode.

---

### Kernel (ntoskrnl)

Handles:

- Process object allocation
- Security enforcement
- Memory setup
- Thread scheduling

All authoritative decisions occur here.

---

### Process Manager

Responsible for:

- EPROCESS lifecycle
- PID assignment
- Parent-child linking

---

### Memory Manager

Responsible for:

- Virtual address space creation
- Section mapping
- Image loading mechanics

---

### Object Manager

Creates and manages the process object.

Assigns:

- Security descriptor
- Handle entries
- Reference counts

---

### Security Reference Monitor (SRM)

Enforces:

- Access control checks
- Token validation
- Privilege enforcement

SRM is central to preventing unauthorized execution.

---

## Token and Security Context

### How the Access Token Is Inherited or Assigned

Default behavior:

- Child process inherits parent's primary token.

Alternate behavior:

- Explicit token supplied via CreateProcessAsUser
- Token duplication or impersonation applied

Token manipulation directly affects privilege boundaries.

---

### Parent Process Token Behavior

If parent is elevated:

- Child inherits elevated token (unless restricted).

If parent is medium integrity:

- Child typically inherits medium integrity.

Privilege escalation often involves manipulating which token is used during creation.

---

### Integrity Level Propagation

Integrity levels propagate from the primary token.

Examples:

- Medium → Medium
- High → High
- SYSTEM → System

Integrity mismatches between parent and child may indicate spoofing or abuse.

---

### Privilege Inheritance

Privileges such as:

- SeDebugPrivilege
- SeImpersonatePrivilege

Are inherited through the primary token unless filtered.

Abuse of these privileges enables lateral movement and escalation.

---

## Parent-Child Relationship Mechanics

### How the Parent Process Is Recorded

The kernel records the creating process ID inside EPROCESS.

This value becomes:

    ParentProcessId (PPID)

The parent-child link is established at kernel level.

---

### What Actually Defines Parentage

Parentage is defined by:

- The process handle used during creation
- Kernel bookkeeping during NtCreateUserProcess

It is not simply the logical origin of execution.

---

### PPID Spoofing Concepts (Conceptual)

Attackers may manipulate process creation attributes to:

- Specify an alternate parent handle
- Create misleading process trees

This alters detection logic based on lineage trust.

---

## Logging and Detection Artifacts

### Security Event ID 4688

Generated when a new process is created.

Contains:

- New Process ID
- Parent Process ID
- Command line
- Token elevation type

---

### Sysmon Event ID 1

Provides enhanced telemetry:

- Full command line
- Parent image
- Hash values
- Integrity level

Critical for behavioral detection.

---

### Command-Line Logging

Command-line arguments often reveal:

- Encoded payloads
- Script execution
- LOLBin abuse

Lack of command-line logging significantly reduces visibility.

---

### Token Elevation Flags

Logs may indicate:

- Elevated token
- Limited token
- Linked token presence (UAC)

Token elevation anomalies often indicate privilege escalation.

---

### Integrity Level Visibility

Logs and telemetry may include:

- Low
- Medium
- High
- System

Unexpected integrity levels require investigation.

---

## Security Implications

### Privilege Escalation Through Process Spawning

Attackers may:

- Spawn a process using a duplicated SYSTEM token
- Use impersonation privileges to create elevated processes

Process creation becomes the pivot point for escalation.

---

### Token Theft + Process Creation Abuse

Attack chain example:

1. Obtain handle to SYSTEM token
2. Duplicate token
3. Call CreateProcessAsUser
4. Spawn SYSTEM shell

Process creation is the final stage of escalation.

---

### Suspicious Parent-Child Chains

Examples:

- Office → cmd.exe
- Browser → powershell.exe
- Service → interactive shell

Abnormal lineage is often the earliest detection opportunity.

---

### Living-Off-the-Land Binaries (LOLBins) Execution

Attackers leverage legitimate binaries:

- rundll32.exe
- mshta.exe
- wmic.exe
- powershell.exe

The creation event appears legitimate without contextual analysis.

---

### Process Hollowing Timing Relevance

Process hollowing typically occurs:

1. Process created in suspended state
2. Memory modified
3. Thread resumed

Understanding creation timing helps detect injection between steps.

---

## Defensive Perspective (SOC Focus)

### Correlating Process Trees

Build full execution chains:

- Initial entry point
- Privilege changes
- Lateral movement steps

Isolated events lack context.

---

### Identifying Abnormal Parent-Child Chains

Baseline expected relationships.

Alert when:

- System processes spawn user apps
- Unexpected services spawn scripting engines
- PPID mismatch with integrity level

---

### Detecting Elevated Token Misuse

Investigate:

- Medium parent spawning System child
- Sudden privilege increase
- SeImpersonatePrivilege usage patterns

---

### Importance of Command-Line Auditing

Command-line logging enables detection of:

- Encoded commands
- Download cradles
- Suspicious arguments

Without it, investigation quality degrades significantly.

---

## Key Takeaways

- Process creation is a controlled, kernel-mediated operation.
- NtCreateUserProcess is the critical transition point into kernel enforcement.
- Tokens and integrity levels define execution context.
- Parent-child relationships are kernel-recorded and security-relevant.
- Most attacks manifest as suspicious process behavior.
- Strong detection relies on understanding the full creation sequence.

Deep knowledge of Windows process creation enables defenders to detect privilege escalation, token abuse, injection timing, and execution anomalies with precision. Process creation is not merely a system function; it is one of the most powerful observability anchors in modern endpoint security.