# 04 - ASLR and DEP

## Overview

Memory exploitation is a class of attack techniques that abuse memory corruption vulnerabilities in software in order to manipulate program execution. Common examples include buffer overflows, use-after-free vulnerabilities, and heap corruption. These attacks typically attempt to redirect execution flow toward attacker-controlled code or toward carefully constructed instruction sequences.

Historically, exploitation was easier because memory layouts in processes were predictable. Attackers could reliably target known memory addresses containing executable code or injected payloads.

To mitigate these attacks, modern operating systems implement exploit mitigation technologies designed to make exploitation unreliable or significantly more difficult. Windows includes several such protections, two of the most important being Address Space Layout Randomization (ASLR) and Data Execution Prevention (DEP).

These technologies are fundamental components of the Windows memory security model and play a critical role in defending against memory corruption attacks.

---

## Address Space Layout Randomization (ASLR)

### What ASLR Is

Address Space Layout Randomization is a security mitigation that randomizes the memory addresses used by a process. Instead of loading program components into predictable locations, Windows places them at randomized addresses each time a process starts.

This randomization prevents attackers from reliably predicting where critical memory regions or executable code will reside.

Without ASLR, memory layouts might appear as follows:

    Executable Image   -> 0x00400000
    Stack              -> 0x0012F000
    Heap               -> 0x00350000
    System DLLs        -> Fixed addresses

With ASLR enabled, these regions are loaded at different locations every time the process runs.

---

### Why Predictable Memory Addresses Are Dangerous

Many classic exploitation techniques rely on knowing the exact address of executable code. If attackers know where useful instructions exist in memory, they can redirect execution flow to those addresses.

Predictable addresses allow attackers to:

- Jump to shellcode injected into memory
- Redirect execution to system functions
- Build reliable exploitation chains

Randomizing memory locations removes this predictability and breaks many exploit assumptions.

---

### What Windows Randomizes

Windows can randomize multiple components within a process address space.

These include:

- Executable image base addresses
- Loaded DLL modules
- Heap memory regions
- Stack locations
- Memory mappings

By randomizing these components independently, Windows increases entropy within the process memory layout.

---

## How ASLR Works in Windows

### Randomization During Process Startup

When a process starts, the Windows loader is responsible for mapping the executable image and required libraries into the process address space.

If ASLR is enabled, the loader chooses randomized base addresses within the allowed address range.

Example conceptual process:

    Process starts
        -> Windows loader initializes
            -> Random base address selected
                -> Executable image mapped
                    -> Required DLLs loaded at randomized locations

Each process instance receives a different memory layout.

---

### Image Base Randomization

Executable files and dynamic libraries contain a preferred image base address. With ASLR enabled, Windows may ignore this preferred address and instead relocate the image to a randomized location.

Relocation entries within the executable allow the loader to adjust internal references so that the program functions correctly even when loaded at a different address.

---

### DLL Relocation

DLL modules are also randomized during loading. If the preferred base address is unavailable or ASLR randomization is active, the Windows loader relocates the DLL to a randomized address.

This relocation increases the difficulty of predicting where useful instructions reside.

---

### Interaction with the Windows Loader

The Windows loader is responsible for applying ASLR during process initialization. It examines executable headers to determine whether the binary supports relocation.

If relocation support exists, the loader can randomize the image base address and adjust internal pointers accordingly.

Applications compiled with ASLR support benefit from full address randomization.

---

## Security Benefits of ASLR

ASLR significantly increases the difficulty of exploiting memory corruption vulnerabilities.

### Protection Against Buffer Overflow Exploits

Buffer overflow attacks often attempt to overwrite return addresses with pointers to attacker-controlled payloads. If memory locations are randomized, attackers cannot reliably predict where payloads reside.

---

### Reduction of Return-Oriented Programming Reliability

Return-Oriented Programming (ROP) attacks depend on chaining together small instruction sequences already present in memory.

These sequences are called gadgets and are typically located within executable modules.

ASLR makes it difficult to locate these gadgets because module addresses change each time the process runs.

---

### Prevention of Predictable Jump Addresses

Without ASLR, attackers could reliably jump to specific instructions within system libraries.

Randomization removes the predictability of these addresses, forcing attackers to rely on additional vulnerabilities.

---

## Limitations of ASLR

Although ASLR is a powerful mitigation, it is not perfect.

### Information Disclosure Vulnerabilities

If an attacker can read memory contents, they may discover randomized addresses. This type of vulnerability is known as an information disclosure.

Once addresses are revealed, the attacker can bypass ASLR protections.

---

### Memory Leaks Revealing Addresses

Applications that unintentionally expose pointers or memory addresses may leak information that reveals the process memory layout.

These leaks can significantly weaken ASLR effectiveness.

---

### Partial ASLR Bypass Techniques

Some exploitation techniques rely on brute force or partial address knowledge. If enough bits of an address are predictable, attackers may still achieve reliable exploitation.

---

### Legacy Applications Without ASLR Support

Older applications compiled without relocation support cannot be fully randomized. Such programs remain vulnerable to predictable memory layouts.

---

## Data Execution Prevention (DEP)

### What DEP Is

Data Execution Prevention is a security technology that prevents execution of code from memory regions intended for data storage.

DEP enforces a strict separation between memory that stores data and memory that contains executable code.

If a program attempts to execute instructions from a non-executable memory region, the processor generates an exception.

---

### Why Executing Code From Data Memory Is Dangerous

Many traditional exploits inject malicious code into writable memory regions such as the stack or heap. If the system allows execution from these regions, the injected code can run immediately.

DEP prevents this behavior by marking such regions as non-executable.

---

### Concept of Non-Executable Memory Pages

Modern operating systems designate memory pages as either executable or non-executable. Data regions such as stack buffers and heap allocations are typically marked as non-executable.

Only code segments belonging to program binaries or trusted modules are allowed to execute.

---

## How DEP Works

### NX Bit in Modern CPUs

Modern processors include a hardware feature known as the NX (No Execute) bit. This bit is stored within page table entries.

If the NX bit is set for a memory page, the CPU will refuse to execute instructions from that page.

Attempting execution results in a protection fault.

---

### Windows Enforcement of Memory Permissions

Windows configures page protections when allocating or mapping memory. These protections determine whether the memory can be read, written, or executed.

Typical protection configuration:

    Code Section     -> Read + Execute
    Stack Memory     -> Read + Write
    Heap Memory      -> Read + Write

Execution is only allowed in memory regions explicitly marked as executable.

---

### Interaction with VirtualAlloc and Protection Flags

Applications that use VirtualAlloc can specify memory protection attributes when allocating memory.

Example conceptual flags include:

    PAGE_READWRITE
    PAGE_EXECUTE
    PAGE_EXECUTE_READ
    PAGE_EXECUTE_READWRITE

Security monitoring tools often watch for suspicious transitions such as writable memory being converted into executable memory.

---

## Security Benefits of DEP

DEP prevents several common exploitation techniques.

### Prevention of Shellcode Execution on the Stack

Stack-based buffer overflow attacks traditionally injected shellcode directly into stack buffers.

DEP prevents execution from stack memory, blocking this technique.

---

### Prevention of Shellcode Execution on the Heap

Attackers sometimes inject payloads into heap buffers and redirect execution to those locations.

Because heap pages are typically marked non-executable, DEP blocks such execution attempts.

---

### Protection Against Classic Buffer Overflow Exploits

DEP disrupts many classic exploitation techniques that rely on executing injected machine code within writable memory.

---

## Limitations and Bypass Techniques

Attackers have developed techniques that bypass DEP protections.

### Return-Oriented Programming (ROP)

Return-Oriented Programming does not require injected code. Instead, attackers reuse small instruction sequences already present in executable memory.

These instruction fragments are chained together to perform malicious operations.

---

### Jump-Oriented Programming (JOP)

Jump-Oriented Programming is similar to ROP but relies on indirect jump instructions rather than return instructions.

Both techniques reuse existing executable code rather than injecting new code.

---

### Reusing Existing Executable Code

Because DEP only prevents execution in non-executable memory, attackers can still exploit vulnerabilities by redirecting execution toward legitimate executable instructions.

---

## Combined Protection: ASLR and DEP

ASLR and DEP provide stronger protection when used together.

DEP prevents execution of injected shellcode, while ASLR prevents attackers from reliably locating useful instruction sequences within memory.

Together they force attackers to overcome two challenges:

    1. Executable memory restrictions
    2. Unpredictable memory locations

This layered defense significantly increases exploitation complexity.

---

## SOC and Detection Perspective

Exploit mitigations are important signals for defenders because many exploit attempts generate observable behaviors.

Indicators of possible exploitation include:

- Crashes triggered by memory protection violations
- Repeated access violations in vulnerable processes
- Attempts to execute code from non-executable memory regions

Suspicious memory behavior may also involve abnormal use of memory allocation APIs.

For example:

    Process allocates memory
        -> Changes memory permissions
            -> Executes code from the region

Such patterns are commonly associated with shellcode staging or fileless malware.

Endpoint Detection and Response systems frequently detect exploitation attempts by monitoring:

- Executable memory allocations
- Memory permission changes
- Abnormal module loading behavior
- Exploit mitigation violations

Understanding ASLR and DEP helps analysts interpret these alerts and identify the techniques attackers are attempting to use.

---

## Key Takeaways

ASLR and DEP are core exploit mitigation technologies used by Windows to defend against memory corruption attacks.

ASLR randomizes memory layouts so attackers cannot reliably predict the location of executable code or critical memory regions.

DEP prevents execution of code from memory regions designated for data, blocking many traditional shellcode injection techniques.

Although attackers have developed bypass strategies such as ROP and JOP, these mitigations significantly increase the difficulty and complexity of exploitation.

For defenders, understanding these protections provides critical context when analyzing crashes, memory protection violations, and exploit-related alerts generated by security monitoring tools.