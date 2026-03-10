# 05 - Memory Abuse and Fileless Attacks

## Overview

Memory abuse refers to the use of a system’s volatile memory to execute malicious operations without relying on traditional files stored on disk. In Windows environments, attackers increasingly exploit memory mechanisms to run payloads directly within process memory, avoiding artifacts that would normally trigger traditional detection mechanisms.

Fileless malware is a form of malicious activity where attackers operate primarily in memory using legitimate system tools and built-in Windows functionality. Instead of writing executable files to disk, attackers leverage scripting engines, memory injection, and existing trusted processes to execute their code.

These techniques are attractive because they reduce forensic evidence, evade signature-based detection, and blend malicious activity with normal operating system behavior. Understanding how Windows manages memory is therefore critical for understanding how attackers exploit these mechanisms and how defenders can detect them.

---

## Windows Memory Execution Model

### Process Memory Layout

Every Windows process operates within its own virtual address space. This address space is divided into several regions used for different purposes during program execution.

Typical process memory regions include:

Stack  
Used for function execution and temporary variables.

Heap  
Used for dynamically allocated memory during runtime.

Image Region  
Contains the executable image and loaded modules.

Memory-Mapped Regions  
Used for mapped files, shared memory, and dynamically allocated memory segments.

A simplified representation of a process address space:

    High Memory
        |
        |  Stack
        |
        |  Heap
        |
        |  Loaded DLLs
        |
        |  Executable Image
        |
        |  Memory Mapped Regions
        |
    Low Memory

Attackers often target these regions to store or execute malicious payloads.

---

### Executable Memory Pages

Memory in Windows is divided into pages that include protection attributes. Pages containing executable code are typically mapped as executable and readable, while data regions such as stack and heap are usually marked as writable but not executable.

Executable pages typically belong to:

- Application code segments
- Loaded dynamic libraries
- JIT-compiled runtime environments

If an attacker manages to allocate executable memory or change the permissions of existing memory pages, malicious code can be executed directly within a process.

---

### Memory Permissions

Each memory page has protection attributes defining how it can be accessed.

Common memory permissions include:

Read  
Allows data to be read from memory.

Write  
Allows modification of memory contents.

Execute  
Allows instructions stored in memory to be executed by the CPU.

Attackers frequently manipulate these permissions to enable execution of injected code.

Example:

    Writable memory allocated
        -> Memory protection changed to executable
            -> Payload executed

---

### Interaction with the Windows Memory Manager

The Windows Memory Manager is responsible for allocating, mapping, and protecting memory regions for each process.

Applications interact with the memory manager through APIs such as memory allocation functions and protection flag changes. When attackers exploit these mechanisms, they are effectively abusing normal operating system functionality.

Malicious activity often involves:

- Allocating memory inside a process
- Writing shellcode into the allocated region
- Changing page permissions
- Redirecting execution to the injected code

---

## Why Fileless Attacks Work

### Avoiding Disk Artifacts

Traditional malware leaves artifacts on disk such as executable files, libraries, or scripts. Fileless techniques eliminate these artifacts by operating entirely within memory.

Without files on disk, many security products cannot rely on signature-based scanning.

---

### Bypassing Traditional Antivirus Detection

Legacy antivirus systems primarily focus on scanning files before execution. When malicious code runs exclusively in memory, these tools may not observe the payload until after execution begins.

Attackers exploit this limitation by staging payloads in memory using scripting engines or injected shellcode.

---

### Leveraging Trusted System Processes

Fileless malware frequently runs inside legitimate Windows processes. By injecting into trusted processes, attackers gain several advantages:

- Reduced suspicion from security tools
- Inherited privileges of the target process
- Ability to blend malicious activity with legitimate system behavior

Processes commonly abused include scripting engines, system utilities, and service hosts.

---

## Common Memory Abuse Techniques

### Reflective DLL Loading

Reflective DLL loading allows attackers to load a dynamic library directly from memory rather than from disk.

Instead of using the normal Windows loader, the malicious code manually maps the DLL into memory and resolves its dependencies.

This technique enables attackers to execute complex payloads without creating a DLL file on disk.

---

### Shellcode Injection

Shellcode injection involves inserting raw machine instructions into the memory of a running process.

The general process follows this pattern:

    Allocate memory inside target process
        -> Write shellcode payload
            -> Redirect execution to injected code

The injected shellcode then executes within the context of the target process.

---

### Process Hollowing

Process hollowing is a technique where attackers create a legitimate process and then replace its memory contents with malicious code.

Typical sequence:

    Create legitimate process in suspended state
        -> Remove original executable image
            -> Inject malicious payload
                -> Resume process execution

The resulting process appears legitimate but executes attacker-controlled instructions.

---

### DLL Injection

DLL injection involves forcing a process to load a malicious dynamic library.

Attackers may trigger this using remote thread creation or other mechanisms that cause the target process to load a library controlled by the attacker.

Once loaded, the malicious DLL executes inside the target process.

---

### PowerShell In-Memory Execution

PowerShell provides powerful scripting capabilities that can execute commands directly from memory.

Attackers often encode scripts or download payloads dynamically during runtime.

Typical flow:

    PowerShell launched
        -> Script downloads payload
            -> Payload executed in memory

Because PowerShell is a legitimate administrative tool, its misuse may initially appear normal.

---

### WMI-Based Execution

Windows Management Instrumentation (WMI) allows remote and local execution of commands using management interfaces.

Attackers use WMI to trigger in-memory execution without creating new binaries on disk.

WMI-based attacks often combine remote execution with PowerShell or script-based payloads.

---

## Security Mitigations

### Data Execution Prevention (DEP)

DEP prevents execution of code from memory regions designated for data storage.

By marking stack and heap pages as non-executable, DEP blocks many traditional shellcode injection techniques.

---

### Address Space Layout Randomization (ASLR)

ASLR randomizes the location of important memory regions such as stacks, heaps, and modules.

This randomization makes it significantly harder for attackers to reliably redirect execution to known memory addresses.

---

### Memory Protection Flags

Windows memory pages include protection flags that control read, write, and execute permissions.

Changing these flags at runtime may indicate suspicious behavior, particularly when writable memory becomes executable.

---

### Control Flow Guard (CFG)

Control Flow Guard is a Windows exploit mitigation that protects against control flow hijacking.

CFG ensures that indirect calls and jumps only target valid, pre-defined locations within executable code.

If execution attempts to jump to an invalid location, the operating system terminates the process.

---

## Indicators of Memory-Based Attacks

Memory abuse often produces observable indicators within system telemetry.

Examples include:

Suspicious Memory Allocations  
Processes allocating executable memory or repeatedly modifying memory permissions.

Unexpected Code Execution  
Code executing from heap or dynamically allocated memory regions.

Abnormal Process Relationships  
Scripting engines spawning unexpected child processes.

Unusual PowerShell Activity  
Encoded commands, hidden execution flags, or remote script downloads.

Such patterns frequently indicate attempts to stage payloads in memory.

---

## Detection and SOC Perspective

Defenders rely on behavioral monitoring to detect memory-based attacks.

Monitoring process memory activity can reveal unusual behavior such as:

    Process allocates memory
        -> Writes payload
            -> Changes permissions to executable
                -> Executes injected code

These patterns are common across multiple injection techniques.

Security telemetry sources are essential for visibility into these activities.

Important telemetry sources include:

Sysmon  
Provides detailed logging for process creation, memory injection, and module loading.

Event Tracing for Windows (ETW)  
Captures low-level system activity used by security tools.

Endpoint Detection and Response (EDR)  
Correlates behavioral signals to detect exploitation attempts.

Behavioral detection focuses on identifying suspicious activity patterns rather than static signatures.

---

## Real-World Impact

Fileless malware techniques are widely used in advanced threats because they minimize detection risk and reduce forensic evidence.

Attackers often combine multiple techniques such as scripting abuse, process injection, and memory-resident payloads to maintain control over compromised systems.

Persistence mechanisms may also operate in memory through scheduled tasks, WMI event subscriptions, or registry-based triggers that execute in-memory payloads.

Because these attacks rely heavily on legitimate system functionality, detecting them requires careful analysis of behavioral anomalies.

---

## Key Takeaways

Memory abuse techniques leverage the Windows memory architecture to execute malicious code without leaving traditional file artifacts.

Fileless attacks rely on in-memory execution, scripting engines, and process injection to evade conventional detection mechanisms.

Common techniques such as process hollowing, shellcode injection, and reflective DLL loading exploit legitimate operating system functionality.

Exploit mitigation technologies such as DEP, ASLR, and Control Flow Guard significantly increase the difficulty of successful memory exploitation.

Defenders must rely on behavioral monitoring, process telemetry, and memory analysis to detect these attacks effectively.

Understanding how attackers manipulate process memory allows security analysts to better investigate alerts, identify exploitation attempts, and recognize patterns associated with modern fileless malware.