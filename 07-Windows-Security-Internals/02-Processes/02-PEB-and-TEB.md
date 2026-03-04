# 02-PEB-and-TEB.md

## Overview

### What PEB and TEB Are

The Process Environment Block (PEB) and Thread Environment Block (TEB) are internal user-mode data structures used by Windows to maintain runtime metadata about processes and threads.

- The PEB contains process-wide information.
- The TEB contains thread-specific information.

These structures are not officially documented for public API use, but they are fundamental to how Windows manages execution context, module loading, and runtime state.

### Where They Exist in Memory

Both PEB and TEB reside in user-mode virtual memory:

- Each process has one PEB.
- Each thread has its own TEB.

They are mapped into the process address space and are accessible from user mode, though direct access is considered low-level and sensitive.

### Why They Are Important in Windows Process Architecture

The Windows loader, runtime libraries, and exception handling mechanisms depend on PEB and TEB structures.

They provide:

- Metadata about loaded modules
- Process parameters (command line, environment)
- Thread-local storage
- Exception handling chains

From a security perspective, many malware and injection techniques directly manipulate these structures.

---

## Process Environment Block (PEB)

### Purpose of the PEB

The PEB stores process-level metadata required by:

- The Windows loader
- Runtime libraries
- Debugging subsystems

It acts as a central structure for tracking process configuration and loaded modules.

---

### Location in User-Mode Memory

The PEB is located in the user-mode address space.

Conceptually:

    User Process Memory
        ├── Code
        ├── Heap
        ├── Stack(s)
        └── PEB

Its address is stored in a thread-accessible location and can be retrieved programmatically.

---

### Key Fields

Commonly abused fields include:

- BeingDebugged  
  Indicates whether the process is being debugged.

- Ldr  
  Pointer to loader data (PEB_LDR_DATA), which contains linked lists of loaded modules.

- ProcessParameters  
  Pointer to RTL_USER_PROCESS_PARAMETERS structure, containing:
  - Command line
  - Image path
  - Environment variables

- ImageBaseAddress  
  Base address where the executable image is mapped in memory.

These fields are frequently inspected or modified by offensive tooling.

---

### Role in DLL Loading and Process Metadata

The loader maintains module lists in:

    InLoadOrderModuleList
    InMemoryOrderModuleList
    InInitializationOrderModuleList

These lists allow:

- Runtime module enumeration
- Import resolution
- API lookup via manual traversal

Manual DLL resolution techniques use these lists to avoid calling monitored APIs.

---

## Thread Environment Block (TEB)

### Purpose of the TEB

The TEB stores thread-specific data, including:

- Thread ID
- Stack limits
- Exception handling structures
- Thread Local Storage (TLS)

Each thread has exactly one TEB.

---

### Relationship Between TEB and PEB

The TEB contains a pointer to the PEB.

Conceptually:

    TEB
      └── Pointer to PEB

This allows any executing thread to locate process-wide metadata.

---

### Thread-Local Storage (TLS)

TLS allows threads to maintain independent copies of data.

The TEB tracks:

- TLS slots
- TLS expansion slots

Malware sometimes abuses TLS callbacks for stealth execution before main entry points.

---

### Exception Handling Structures

On x86 systems, structured exception handling (SEH) chains are stored in the TEB.

Attackers historically abused SEH overwrite vulnerabilities for code execution.

Although mitigations exist, TEB remains central to exception handling logic.

---

## Accessing PEB and TEB

### How User-Mode Code References Them

User-mode code can retrieve the PEB through the TEB.

Conceptual example (x64):

    GS register → TEB → PEB pointer

On x86:

    FS register → TEB

The exact offsets differ by architecture and Windows version.

---

### Segment Registers (FS/GS) Usage Conceptually

- x86: FS points to TEB
- x64: GS points to TEB

This provides fast access to thread-specific data without function calls.

Direct structure walking is common in shellcode and reflective loaders.

---

### Why Direct Access Is Sensitive

Because PEB and TEB are writable in user mode:

- Malware can modify fields
- Debugging flags can be altered
- Module lists can be tampered with

Security tools must validate assumptions rather than trust user-mode metadata blindly.

---

## Security Implications

### Anti-Debugging Techniques (BeingDebugged Flag)

Malware commonly checks:

    PEB->BeingDebugged

If set, execution may:

- Terminate
- Alter behavior
- Trigger anti-analysis routines

This avoids standard API-based detection such as IsDebuggerPresent().

---

### Manual DLL Resolution and Reflective Loading

Shellcode often:

1. Walks PEB module lists
2. Locates kernel32.dll base
3. Resolves exports manually
4. Calls functions without using imports

This bypasses API monitoring and import-based detection.

Reflective DLL loaders avoid standard LoadLibrary mechanisms by manually mapping modules.

---

### Shellcode and Malware Behavior

Shellcode frequently:

- Locates PEB
- Traverses InMemoryOrderModuleList
- Resolves function addresses dynamically

This minimizes detectable API usage.

---

### Hiding Modules from the Loader List

Attackers may unlink malicious modules from:

    InLoadOrderModuleList

This hides the module from:

- Toolhelp32 snapshots
- EnumProcessModules
- Standard enumeration APIs

However, memory artifacts still exist and can be detected via raw memory analysis.

---

### EDR Visibility Considerations

Many EDR solutions rely on:

- API monitoring
- Module load notifications
- User-mode hooks

If malware resolves functions manually via PEB traversal, it may evade user-mode API hooks.

Kernel-level telemetry is required for stronger detection.

---

## Abuse Scenarios

### Process Injection and PEB Manipulation

After injecting into a process, attackers may:

- Modify ProcessParameters
- Spoof command line arguments
- Alter ImagePathName

This creates misleading telemetry.

---

### Unlinking Modules from InLoadOrderModuleList

Steps conceptually:

1. Locate PEB
2. Access Ldr structure
3. Modify linked list pointers
4. Remove module entry

The module remains mapped but invisible to common enumeration methods.

---

### Spoofing Process Parameters

Attackers may overwrite:

    RTL_USER_PROCESS_PARAMETERS.CommandLine

This causes security tools relying on user-mode inspection to log false command lines.

---

### Bypassing User-Mode Hooks

Instead of calling:

    GetProcAddress()
    LoadLibrary()

Malware:

- Walks export tables manually
- Uses direct system calls
- Avoids monitored APIs

This reduces visibility for user-mode EDR components.

---

## Defensive and SOC Perspective

### Indicators of PEB Tampering

Potential indicators:

- Mismatch between loaded modules in memory and PEB lists
- Command-line discrepancies between kernel telemetry and user-mode inspection
- Abnormal linked list structures

Cross-validation is essential.

---

### Memory Inspection Considerations

Forensic memory analysis should:

- Reconstruct module lists independently
- Validate linked list integrity
- Compare VAD (Virtual Address Descriptor) mappings with PEB entries

Unlinked modules are strong indicators of stealth activity.

---

### Why Abnormal Module Lists Are Suspicious

If a module:

- Exists in memory
- Has executable permissions
- Is not referenced in PEB loader lists

It may indicate:

- Reflective loading
- Manual mapping
- Loader tampering

---

### Relevance During Forensic Memory Analysis

PEB and TEB structures help investigators:

- Identify hidden modules
- Recover real command-line arguments
- Detect injection artifacts
- Identify anti-debugging logic

Memory forensics tools frequently reconstruct process state independent of PEB trust.

---

## Key Takeaways

- PEB and TEB store critical runtime metadata for processes and threads.
- They reside in user-mode memory but directly influence loader and runtime behavior.
- Malware commonly manipulates these structures for anti-debugging and stealth.
- Reflective DLL loading and manual API resolution rely heavily on PEB traversal.
- User-mode monitoring alone is insufficient; cross-layer validation is required.
- Memory forensics must verify module lists and process parameters independently.

Understanding PEB and TEB is essential for analyzing process injection, anti-debugging behavior, reflective loading techniques, EDR evasion strategies, and advanced memory-resident threats. These structures form a foundational layer of Windows process internals and represent a critical analysis surface for defenders.