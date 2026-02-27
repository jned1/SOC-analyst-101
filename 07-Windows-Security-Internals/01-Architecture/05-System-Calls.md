# 05-System-Calls.md

## Overview

System calls (syscalls) are the primary interface between user-mode applications and kernel-mode operations in Windows. They provide controlled, secure access to privileged functionality while enforcing process isolation and memory protection. Understanding syscalls is essential for analyzing malware behavior, privilege escalation, and kernel-level attacks in a blue team context.

---

## What System Calls Are

A system call is a request from a user-mode application to the operating system kernel to perform a privileged operation. Examples include:

- Creating or opening files (`NtCreateFile`)  
- Managing processes and threads  
- Allocating or freeing memory  
- Querying security information  

Syscalls act as the boundary between Ring 3 (user mode) and Ring 0 (kernel mode), enforcing separation between unprivileged code and sensitive system resources.

---

## Why Windows Separates User-Mode Applications from Kernel-Mode Execution

Windows enforces a strict security boundary:

- **User Mode (Ring 3):** Limited privileges, memory protection, cannot execute privileged instructions  
- **Kernel Mode (Ring 0):** Full access to memory, hardware, and system structures  

This separation prevents accidental or malicious user-mode code from directly manipulating kernel structures, limiting the scope of potential exploits.

---

## System Call Mechanism

### How User-Mode Applications Invoke Kernel Functions

1. Applications call a high-level API (Win32 API in `user32.dll` or `kernel32.dll`)  
2. These APIs often wrap Native API functions in `ntdll.dll`  
3. Native API functions issue a software interrupt or a `syscall` instruction  
4. Control transfers from user mode to kernel mode  

Example flow:

    user32.dll → kernel32.dll → ntdll.dll → syscall → Kernel Dispatcher

---

### Role of the Syscall Dispatcher

The kernel syscall dispatcher:

- Validates the system call number  
- Checks arguments and access rights  
- Maps the request to the corresponding kernel service routine in the Executive or Kernel  
- Returns the result to user mode  

This centralized mediation enforces consistent access control.

---

### Context Switching from User Mode to Kernel Mode

During a syscall:

- CPU transitions from Ring 3 to Ring 0  
- Kernel stack replaces user-mode stack  
- Registers are saved and restored upon return  

This switch ensures that user-mode code cannot directly manipulate kernel execution state.

---

### Typical System Call Flow (Example: NtCreateFile)

    1. User-mode application calls CreateFile()  
    2. Win32 API translates to NtCreateFile() in ntdll.dll  
    3. NtCreateFile executes a `syscall` instruction  
    4. CPU switches to Ring 0, entering the syscall dispatcher  
    5. Object Manager and I/O Manager handle the request  
    6. Result or error code returned to user mode  

---

## Windows System Call Table

### Organization of System Calls

- The kernel maintains a system call table mapping syscall numbers to internal kernel routines  
- Each syscall has a unique identifier, enabling dispatcher lookup  

### Native API (ntdll) vs Win32 API

- **Win32 API:** High-level, user-friendly interface for applications  
- **Native API (ntdll):** Direct access to kernel services, less abstracted  

Attackers often target Native API calls to bypass user-mode API restrictions or monitoring.

### Importance for Security Monitoring

Syscalls are a key visibility point for detecting:

- Unauthorized access to system objects  
- Privilege escalation attempts  
- Kernel-mode malware interactions  

---

## Security Implications

### How Attackers Abuse System Calls for Privilege Escalation

- Direct invocation of Native API functions to manipulate tokens  
- Exploiting vulnerable kernel-mode drivers via crafted syscalls  
- Skipping user-mode access checks  

### Hooking and Tampering with Syscalls

- Rootkits may patch the syscall table or inline hook `ntdll.dll` functions  
- This allows interception or modification of privileged operations without detection  

### Detecting Anomalous Syscall Patterns

Indicators include:

- Unexpected syscall sequences  
- Calls from unusual processes or memory regions  
- Repeated high-frequency access to privileged services  

### Relevance for Rootkits and Malware

- Malware may bypass Win32 API monitoring by calling syscalls directly  
- Understanding syscall flow is crucial for detecting stealthy kernel or process-level attacks  

---

## Monitoring and Defensive Perspective

### Observing Syscalls in User-Space vs Kernel-Space

- **User-Space Monitoring:** ETW (Event Tracing for Windows), Sysmon, Procmon capture syscall-related activity  
- **Kernel-Space Monitoring:** Advanced kernel callbacks, filter drivers, hypervisor-based monitoring  

### Tools for Syscall Monitoring

- **ETW (Event Tracing for Windows):** Records kernel events and syscall activity  
- **Sysmon:** Monitors process creation, network connections, file access events tied to syscalls  
- **Procmon:** Provides detailed syscall-level tracing for debugging and security analysis  

### Indicators of Malicious Syscall Activity

- Direct calls to sensitive Native API functions from non-standard processes  
- High-frequency calls to `NtOpenProcess` or `NtQuerySystemInformation`  
- Irregular handle manipulation, token duplication, or memory allocation patterns  

---

## Key Takeaways

- System calls enforce controlled access from user mode to kernel operations.  
- Understanding syscall flow clarifies how privileged operations are executed and monitored.  
- Syscalls are a common vector for privilege escalation, rootkits, and kernel abuse.  
- Monitoring syscall activity bridges Windows internals knowledge to SOC operations, enabling detection of stealthy attacks and malicious process behavior.  
- Mastery of syscalls is essential for linking application behavior to kernel-level security monitoring and defensive strategies.