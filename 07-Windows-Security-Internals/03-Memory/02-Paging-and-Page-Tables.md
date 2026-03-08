# 02 - Paging and Page Tables

## Overview

Paging is a core mechanism used by modern operating systems to implement virtual memory. Instead of treating memory as a single continuous region, the system divides memory into fixed-size blocks called pages. These pages are mapped between virtual address spaces used by processes and the physical memory installed in the system.

Windows relies heavily on paging to provide each process with its own isolated virtual address space while efficiently using available physical memory. The paging system allows the operating system to manage memory dynamically, enforce security boundaries, and support large address spaces even when physical memory is limited.

From a security perspective, paging mechanisms define how memory access is controlled and isolated. Many memory-based attacks attempt to manipulate or bypass paging protections in order to execute malicious code or gain elevated privileges.

---

## Memory Pages

### Definition of a Memory Page

A memory page is a fixed-size block of memory used by the operating system for memory management. Instead of managing memory byte-by-byte, Windows allocates and manages memory in page-sized units.

Paging simplifies memory allocation and makes it possible to map virtual memory to physical memory efficiently.

---

### Typical Page Sizes Used by Windows

On most modern Windows systems, the standard page size is:

    4 KB (4096 bytes)

In addition to standard pages, Windows may use larger page sizes for performance optimization, such as large pages used in certain high-performance workloads.

However, the 4 KB page size is the primary unit used for virtual memory management.

---

### Virtual Pages vs Physical Frames

Paging separates memory into two related concepts:

Virtual Pages  
These represent blocks of memory within a process's virtual address space.

Physical Frames  
These represent blocks of actual physical RAM available on the system.

A virtual page does not necessarily correspond directly to a physical frame. Instead, the operating system maps virtual pages to physical frames as needed.

This mapping is managed through page tables.

---

## Page Tables

### What Page Tables Are

Page tables are data structures maintained by the operating system that define how virtual memory addresses map to physical memory locations.

Each process has its own set of page tables describing the layout of its virtual address space.

The page table entries contain information such as:

- Physical memory location
- Access permissions
- Page status
- Paging information

---

### Mapping Virtual Addresses to Physical Memory

When a process attempts to access memory using a virtual address, the system consults the page tables to determine which physical memory frame contains the requested data.

The mapping process looks like:

    Virtual Address -> Page Table Entry -> Physical Frame

If the mapping exists and access permissions are valid, the memory access proceeds.

If not, the system generates a fault that must be handled by the operating system.

---

### Hierarchical Page Table Structure

Modern CPUs use multi-level hierarchical page tables to efficiently manage large address spaces.

Instead of storing a single large table, the system divides page tables into multiple levels that guide the translation process.

A simplified representation of hierarchical paging is:

    Page Directory
        -> Page Table
            -> Page Entry

Each level narrows down the location of the final page mapping.

This hierarchical design reduces memory overhead while allowing the operating system to manage extremely large virtual address spaces.

---

### Role of the Memory Management Unit (MMU)

The Memory Management Unit (MMU) is a hardware component within the CPU responsible for performing address translation.

The MMU:

- Translates virtual addresses into physical addresses
- Consults page tables during translation
- Enforces memory access permissions
- Generates page faults when invalid access occurs

The operating system configures page tables, but the MMU performs the translation in hardware during program execution.

---

## Address Translation Process

### Virtual-to-Physical Address Translation

When a process accesses memory, the following steps occur:

    1. CPU generates a virtual address
    2. MMU checks Translation Lookaside Buffer
    3. If not found, MMU walks page tables
    4. Physical address is determined
    5. Memory access occurs

This process happens extremely quickly and is heavily optimized by modern processors.

---

### Page Table Lookup

If the MMU does not already know the mapping between a virtual address and physical memory, it must perform a page table lookup.

This involves traversing the hierarchical page tables until the correct page table entry is found.

Once found, the physical memory frame is identified.

---

### Translation Lookaside Buffer (TLB)

To improve performance, CPUs include a cache called the Translation Lookaside Buffer.

The TLB stores recently used address translations so that the system does not need to repeatedly walk page tables.

When a virtual address is accessed:

- The MMU first checks the TLB
- If a match is found, translation occurs immediately
- If not, a page table lookup is performed

This caching mechanism significantly improves memory access performance.

---

### Kernel Involvement in Memory Mapping

The Windows kernel maintains the page tables that describe memory mappings.

The Windows Memory Manager updates page tables when:

- Memory is allocated
- Memory is freed
- Page permissions change
- Pages are swapped between RAM and disk

The kernel ensures that each process has its own isolated mapping and that memory protections are enforced.

---

## Paging and the Page File

### Concept of Paging to Disk

Physical RAM is limited. When the system runs out of available memory, inactive pages may be moved from RAM to disk storage.

This process is known as paging or swapping.

Paging allows the system to free physical memory while still preserving application state.

---

### Role of the Windows Pagefile

Windows uses a special file called the pagefile to store paged-out memory.

The pagefile resides on disk and temporarily stores memory pages that are not actively being used.

When a paged-out memory page is needed again, the system loads it back into physical memory.

---

### Swapping Inactive Memory Pages

When a process attempts to access a page that has been moved to disk:

- The MMU detects that the page is not present in RAM
- A page fault is triggered
- The operating system retrieves the page from disk
- The page is loaded back into physical memory

This mechanism allows systems to run applications whose combined memory requirements exceed the amount of available RAM.

---

## Page Protection and Access Flags

### Read, Write, and Execute Permissions

Each page table entry contains access control information that determines how the memory page can be used.

Typical permissions include:

- Read
- Write
- Execute

These permissions enforce memory protection at the hardware level.

---

### Page Protection Bits

Page protection bits stored in page table entries define the allowed operations for each page.

Examples of restrictions include:

- Preventing writes to read-only memory
- Preventing execution of data pages
- Restricting user-mode access to kernel pages

These protections help prevent memory corruption attacks.

---

### Windows Enforcement of Memory Protection

The Windows kernel configures page protections when allocating or mapping memory.

If a process attempts to violate page permissions, the CPU generates a fault and the operating system intervenes.

This mechanism prevents unauthorized memory modification or execution.

---

## Security Implications

### Memory Isolation Between Processes

Paging ensures that each process operates within its own isolated virtual address space.

This isolation prevents processes from reading or modifying each other's memory.

Without paging-based isolation, a compromised application could directly manipulate other programs.

---

### Manipulation of Memory Mappings by Attackers

Advanced attackers attempt to manipulate memory mappings in order to:

- Execute injected code
- Modify protected memory regions
- Redirect program execution

Such attacks often rely on vulnerabilities in memory management or application logic.

---

### Page Table Abuse in Kernel Exploits

Kernel-level exploits sometimes attempt to modify page tables directly.

If an attacker gains the ability to alter page table entries, they may:

- Change memory permissions
- Access protected memory regions
- Execute code in privileged contexts

Because page tables control memory access across the entire system, they are a high-value target for exploitation.

---

### Relation to Exploit Mitigations

Paging supports several important security mitigations.

Examples include:

Data Execution Prevention (DEP)  
Prevents execution of code in memory regions marked as non-executable.

Address Space Layout Randomization (ASLR)  
Randomizes the locations of memory regions to make exploitation more difficult.

Both mitigations rely on page-level protections implemented through paging mechanisms.

---

## Defensive Perspective (SOC Focus)

### Memory Exploitation Targeting Paging Mechanisms

Many advanced attacks attempt to manipulate memory mappings or bypass memory protection.

Techniques may include:

- Injecting code into process memory
- Executing code in unexpected memory regions
- Exploiting vulnerabilities to modify memory protections

Understanding paging behavior helps defenders recognize these activities.

---

### Importance of Monitoring Memory Behavior

Modern security tools monitor memory usage patterns to detect suspicious activity.

Examples include:

- Execution from non-standard memory regions
- Unusual memory permission changes
- Cross-process memory access

These behaviors can indicate exploitation attempts or malicious code execution.

---

### Indicators of Suspicious Memory Manipulation

Security analysts may investigate events such as:

- Rapid changes in page permissions
- Code executing from writable memory
- Processes accessing memory belonging to other processes
- Unexpected memory allocation patterns

Such indicators can reveal attempts to bypass memory protections.

---

## Key Takeaways

Paging divides memory into manageable blocks that allow virtual addresses to map to physical memory efficiently.

Page tables maintain the mapping between virtual pages and physical frames while enforcing access permissions.

Hardware components such as the MMU perform address translation while the Windows kernel manages memory mappings.

Paging enables strong process isolation and supports security protections such as DEP and ASLR.

Understanding paging and page tables is essential for analyzing memory exploitation techniques, privilege escalation vulnerabilities, and advanced attack behavior in modern Windows systems.