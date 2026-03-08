# 01 - Virtual vs Physical Memory

## Overview

Memory management is a fundamental responsibility of an operating system. It determines how programs access memory, how resources are allocated, and how isolation between running processes is enforced.

Modern operating systems such as Windows do not allow applications to interact directly with hardware memory. Instead, Windows implements a **virtual memory system** that provides each process with its own virtual address space while mapping those addresses to physical memory behind the scenes.

This abstraction improves stability, allows efficient resource sharing, and enforces strong security boundaries between processes.

Understanding the distinction between **virtual memory** and **physical memory** is essential for analyzing how Windows enforces process isolation and how attackers attempt to manipulate memory during exploitation or post-compromise activity.

---

## Physical Memory

### What Physical Memory (RAM) Is

Physical memory refers to the actual hardware memory installed in a system, typically in the form of RAM modules.

RAM stores:

- Program instructions
- Application data
- Kernel data structures
- Operating system components

Physical memory is organized as a sequence of addressable locations. Each location has a unique **physical address** that the CPU can use to read or write data.

---

### How the CPU Accesses Physical Memory

At the hardware level, the CPU reads and writes memory using physical addresses. These addresses correspond directly to locations in RAM.

However, modern systems rarely expose physical addressing directly to applications. Instead, the CPU works with virtual addresses that must be translated before memory access occurs.

---

### Limitations of Direct Physical Addressing

Direct physical addressing introduces several limitations:

- Programs could overwrite each other's memory
- Faulty applications could corrupt the operating system
- Memory allocation would be difficult to manage
- Security boundaries between applications would not exist

If multiple programs attempted to use the same physical memory location, system instability or crashes would occur.

---

### Why Direct Physical Access Is Unsafe for User Processes

Allowing user applications direct access to physical memory would introduce severe security risks.

For example, a malicious process could:

- Read credentials from another process
- Modify code belonging to another application
- Corrupt kernel memory structures

To prevent these issues, Windows restricts direct access to physical memory and introduces a layer of abstraction through virtual memory.

---

## Virtual Memory

### Concept of Virtual Address Spaces

Virtual memory provides each process with its own logical memory space known as a **virtual address space**.

Instead of referencing real physical addresses, programs operate using **virtual addresses**. These addresses are translated by the operating system and hardware into physical memory locations.

---

### Per-Process Memory Isolation

Each process receives its own virtual address space. This means that two processes can use identical virtual addresses without interfering with each other.

For example, two different processes may both use the virtual address:

    0x00400000

However, this address maps to completely different physical memory locations for each process.

This design enforces isolation between applications.

---

### How Each Process Believes It Owns Its Own Memory

From the perspective of an application, it appears as though it has access to a large, continuous memory region.

In reality:

- The operating system manages memory mapping
- Only a subset of memory is actively backed by physical RAM
- Some memory may be paged to disk

This abstraction simplifies application development and improves system stability.

---

### Advantages of Virtual Memory in Modern Operating Systems

Virtual memory provides several advantages:

- Process isolation
- Efficient memory utilization
- Ability to run more programs than available physical memory
- Controlled memory protection
- Simplified application design

These features are critical for both system reliability and security enforcement.

---

## Address Translation

### Virtual Address to Physical Address Mapping

When a process accesses memory, it uses a virtual address.

Before the CPU can read or write data, the address must be translated into a physical address. This translation determines the exact location in RAM where the data resides.

---

### Role of the Memory Management Unit (MMU)

The **Memory Management Unit (MMU)** is a hardware component inside the CPU responsible for address translation.

The MMU performs the following tasks:

- Translates virtual addresses into physical addresses
- Enforces memory protection rules
- Prevents unauthorized memory access

If a process attempts to access memory that it is not permitted to access, the MMU generates an exception.

---

### Page Tables and Translation Process

Windows uses a paging system to manage memory.

Memory is divided into fixed-size units called **pages**, typically 4 KB in size.

The operating system maintains **page tables** that define how virtual pages map to physical memory frames.

The translation process involves:

    Virtual Address -> Page Table Lookup -> Physical Address

Each entry in the page table specifies:

- The physical memory location
- Access permissions
- Page status information

---

### Kernel Involvement in Memory Mapping

The Windows kernel maintains page tables and manages memory mappings.

The **Memory Manager** subsystem updates page table entries when:

- Memory is allocated
- Memory is freed
- Pages are swapped to disk
- Access permissions change

This mechanism ensures that processes only access memory they are authorized to use.

---

## User Space vs Kernel Space Memory

### Separation of Memory Regions

Windows separates memory into two main regions:

- User space
- Kernel space

User space is where applications execute. Kernel space is reserved for the operating system and critical system components.

---

### Protection Boundaries

Applications running in user mode cannot access kernel memory.

If a user-mode process attempts to access kernel space, the system generates a fault and prevents the operation.

This boundary protects critical operating system structures.

---

### Why Kernel Memory Must Remain Protected

Kernel memory contains sensitive data structures such as:

- Process management structures
- Device driver code
- Security subsystem data
- System call handlers

Unauthorized access to kernel memory could allow attackers to fully compromise the operating system.

---

## Role of the Windows Memory Manager

### Managing Virtual Address Spaces

The Windows Memory Manager is responsible for controlling virtual memory across the entire system.

It tracks:

- Virtual address space usage
- Page allocations
- Page permissions
- Page faults

Each process has its own virtual address space controlled by the Memory Manager.

---

### Mapping Virtual Pages to Physical Frames

The Memory Manager maps virtual pages to physical memory frames.

If a page is not currently present in physical memory, a **page fault** occurs and the operating system loads the required page from disk or allocates a new physical frame.

---

### Handling Memory Allocation and Paging

The Memory Manager also controls:

- Heap allocations
- Stack allocations
- Memory-mapped files
- Paging operations

When physical memory becomes limited, inactive pages may be moved to disk storage to free RAM for active processes.

---

## Security Implications

### Memory Isolation Between Processes

Virtual memory ensures that processes cannot directly access the memory of other processes.

This isolation is critical for system security and prevents applications from interfering with each other.

---

### Prevention of Unauthorized Memory Access

Memory protection flags enforce access control for memory pages.

Typical permissions include:

- Read
- Write
- Execute

These permissions help prevent malicious code execution or unauthorized data modification.

---

### How Memory Corruption Vulnerabilities Bypass Protections

Some vulnerabilities allow attackers to manipulate memory in unintended ways.

Examples include:

- Buffer overflows
- Use-after-free errors
- Memory corruption bugs

Such vulnerabilities may allow attackers to modify memory structures or redirect program execution.

---

### Importance of Memory Protections for Exploit Mitigation

Modern operating systems implement memory protections to reduce exploitation risk.

These protections rely on the virtual memory system to enforce:

- Execution restrictions
- Memory access boundaries
- Isolation between applications

Without virtual memory protections, exploitation would be significantly easier.

---

## Defensive Perspective (SOC Focus)

### Why Many Attacks Target Memory Manipulation

Attackers frequently target memory because it allows them to execute code without writing files to disk.

Memory-based attacks may evade traditional file-based detection mechanisms.

---

### Memory Injection and Process Hollowing Concepts

Techniques such as **process injection** and **process hollowing** rely heavily on manipulating virtual memory.

These attacks typically involve:

- Allocating memory in another process
- Writing malicious code into that memory
- Executing the injected payload

Understanding how virtual memory works helps defenders recognize these behaviors.

---

### Importance of Memory Monitoring Tools

Security tools monitor memory activity to detect suspicious operations.

These tools may observe:

- Unusual memory allocations
- Execution from non-standard memory regions
- Cross-process memory access

Memory analysis is an important component of modern threat detection.

---

## Key Takeaways

Virtual memory is an abstraction layer that separates application memory access from physical hardware memory.

Each process receives its own isolated virtual address space, which prevents applications from interfering with one another.

The Windows Memory Manager and CPU hardware components translate virtual addresses into physical memory locations while enforcing access permissions.

Memory architecture plays a critical role in maintaining system stability and security boundaries.

Understanding how virtual memory operates helps defenders analyze advanced attack techniques such as memory injection, exploit-based compromise, and process manipulation.