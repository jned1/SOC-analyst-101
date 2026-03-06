# 03 - Stack, Heap, and Memory Allocations

## Overview

Memory plays a central role in how processes execute within Windows. Every running process receives a virtual address space that contains multiple memory regions responsible for different execution tasks. Among the most critical of these regions are the stack and the heap.

The stack and heap serve different purposes in program execution. The stack is optimized for structured and short-lived memory operations associated with function calls, while the heap is designed for dynamic and flexible memory allocation required by applications during runtime.

This separation exists to improve performance, maintain program structure, and enforce memory safety boundaries. From a security standpoint, understanding how stack and heap memory operate is essential because many software vulnerabilities arise from incorrect memory management. Numerous exploitation techniques target weaknesses in these memory regions to gain code execution or escalate privileges.

A clear understanding of stack and heap behavior helps analysts interpret exploitation attempts, memory corruption events, and suspicious runtime activity observed during security investigations.

---

## Stack Memory

### What the Stack Is

The stack is a region of memory used for managing function execution. It stores temporary data needed during the execution of program functions and follows a structured Last-In-First-Out (LIFO) model.

Whenever a function is called, the system creates a new stack frame that contains information necessary to execute that function.

The stack is automatically managed by the CPU and compiler, making it extremely fast for allocating and releasing memory.

---

### Function Call Frames

Each function call creates a stack frame. A stack frame typically contains:

- Function parameters
- Local variables
- Saved CPU registers
- Return address

A simplified representation of a stack frame looks like:

    +------------------------+
    | Function Parameters    |
    +------------------------+
    | Return Address         |
    +------------------------+
    | Saved Registers        |
    +------------------------+
    | Local Variables        |
    +------------------------+

When a function finishes execution, its stack frame is removed and control returns to the calling function using the stored return address.

---

### Local Variables and Return Addresses

Local variables declared inside a function are stored within the stack frame. Because the stack automatically allocates and releases memory during function calls, these variables only exist during the lifetime of the function.

The return address stored in the stack frame is particularly important because it determines where program execution resumes after the function completes.

If an attacker can overwrite the return address, they may redirect execution to malicious code.

---

### Stack Growth Behavior

On Windows systems, the stack typically grows downward in memory. This means that new stack frames are placed at lower memory addresses as additional functions are called.

Example representation:

    High Memory Address
        |
        |   Initial Stack
        |
        v
    +------------------+
    | Stack Frame A    |
    +------------------+
    | Stack Frame B    |
    +------------------+
    | Stack Frame C    |
    +------------------+
        |
        v
    Low Memory Address

Each thread in a process has its own independent stack.

---

### Stack Limits and Protection Mechanisms

Windows defines a maximum stack size for each thread. When the stack reaches its limit, further growth triggers a stack overflow exception.

Operating systems also apply guard pages to detect when the stack approaches its boundary. Guard pages generate exceptions before the stack collides with other memory regions.

---

### Security Relevance: Stack-Based Buffer Overflows

Stack-based buffer overflows occur when a program writes more data into a stack buffer than it was allocated to hold.

If the overflow overwrites the return address within a stack frame, an attacker can redirect execution flow.

Classic exploitation sequence:

    Buffer overflow
        -> Overwrite return address
            -> Redirect execution
                -> Execute malicious payload

Stack overflows historically formed the basis of many remote code execution vulnerabilities.

---

## Heap Memory

### What the Heap Is

The heap is a memory region used for dynamic memory allocation during program execution. Unlike the stack, heap memory is manually managed by the application through operating system APIs.

Heap memory allows programs to allocate memory whose size or lifetime cannot be determined at compile time.

---

### Dynamic Memory Allocation

Applications allocate heap memory when they require data structures that must persist beyond the lifetime of a single function call.

Examples include:

- Objects
- Data buffers
- Linked lists
- Complex data structures

Heap memory remains allocated until it is explicitly released by the program.

---

### How Applications Request Heap Memory

Applications request heap memory using Windows memory allocation APIs. These APIs interact with the Windows memory manager to reserve or commit memory pages within the process address space.

Unlike the stack, heap allocations may occur anywhere within the virtual memory region assigned to the process.

---

### Heap Fragmentation and Memory Management Behavior

Because heap allocations occur dynamically and may vary in size, the heap can become fragmented over time.

Fragmentation occurs when allocated and freed memory blocks create gaps within the heap. The memory manager must track these blocks and reuse available regions efficiently.

Fragmentation can degrade performance and complicate memory management.

---

### Security Implications of Heap Usage

Improper handling of heap memory may result in several classes of vulnerabilities.

Heap corruption occurs when memory structures used by the heap allocator are overwritten or manipulated.

Common heap vulnerabilities include:

- Heap buffer overflows
- Double free errors
- Use-after-free conditions

Such vulnerabilities may allow attackers to manipulate heap metadata or overwrite function pointers used by the program.

---

## Memory Allocation APIs in Windows

### HeapAlloc and HeapFree

HeapAlloc and HeapFree are commonly used APIs that allow applications to allocate and release memory from a process heap.

HeapAlloc requests memory from a heap managed by the operating system. HeapFree releases that memory once it is no longer needed.

These APIs interact with the Windows heap manager, which maintains metadata structures used to track allocated memory blocks.

---

### VirtualAlloc and VirtualFree

VirtualAlloc operates at a lower level than heap allocation APIs. It allows applications to directly request memory pages from the Windows memory manager.

VirtualAlloc can:

- Reserve virtual address space
- Commit physical memory pages
- Configure page protection attributes

Example conceptual behavior:

    Application requests memory
        -> VirtualAlloc reserves address range
            -> Memory manager maps pages
                -> Process receives usable memory

Malware frequently uses VirtualAlloc to allocate executable memory for shellcode.

---

### GlobalAlloc and LocalAlloc (Historical Context)

Older Windows APIs such as GlobalAlloc and LocalAlloc were historically used for memory management.

Modern Windows implementations map these functions internally to heap allocation mechanisms.

Although still supported for compatibility, they are generally replaced by HeapAlloc or VirtualAlloc in modern software.

---

## Stack vs Heap Comparison

Lifetime of Memory Objects

Stack memory is automatically allocated and released during function calls. Heap memory persists until explicitly freed by the application.

Allocation Speed

Stack allocation is extremely fast because it involves simple pointer adjustments. Heap allocation requires more complex memory management and is slower.

Memory Limits

Stack size is limited and predefined for each thread. Heap memory can grow dynamically within the process address space.

Typical Usage Patterns

The stack is used for temporary data and function execution. The heap is used for dynamic objects and long-lived data structures.

Security Risks

Stack vulnerabilities often involve return address manipulation. Heap vulnerabilities typically involve memory corruption or pointer manipulation.

---

## Security Implications

Memory structures such as the stack and heap are frequent targets of exploitation.

Stack buffer overflow attacks attempt to overwrite return addresses to redirect execution flow.

Heap corruption vulnerabilities manipulate heap metadata structures to achieve arbitrary memory writes.

Use-after-free conditions occur when a program continues using memory after it has been released. Attackers may reallocate that memory to control program behavior.

Memory spraying techniques involve allocating large amounts of memory containing attacker-controlled data. This increases the probability that redirected execution will land on malicious instructions.

These techniques form the foundation of many exploitation strategies used against vulnerable software.

---

## Defensive Mechanisms in Windows

Modern Windows systems implement several security mechanisms designed to protect memory structures.

Data Execution Prevention (DEP)

DEP prevents execution of code from memory regions marked as non-executable. This blocks many traditional shellcode injection techniques.

Address Space Layout Randomization (ASLR)

ASLR randomizes the memory locations of important process structures such as stacks, heaps, and loaded modules. This makes it difficult for attackers to predict memory addresses.

Stack Cookies (Stack Canaries)

Stack cookies are security values inserted before return addresses within stack frames. If a buffer overflow occurs, the cookie value changes and the system detects the corruption.

Heap Protection Mechanisms

The Windows heap manager includes multiple integrity checks and metadata protections designed to detect corruption attempts.

These mitigations significantly increase the difficulty of exploiting memory vulnerabilities.

---

## SOC and Detection Perspective

Memory behavior is a critical signal in modern threat detection.

Indicators of memory corruption may include:

- Crashes caused by access violations
- Unexpected memory permission changes
- Abnormal process termination patterns

Suspicious memory allocation patterns may indicate exploitation attempts or malware staging activity.

Fileless malware frequently executes directly from memory without writing malicious files to disk. Such attacks rely heavily on dynamic memory allocation APIs.

Security monitoring platforms and endpoint detection systems often detect:

- Executable memory allocations
- Shellcode execution
- Memory injection into other processes

Understanding stack and heap behavior helps analysts interpret these alerts and trace the underlying attack techniques.

---

## Key Takeaways

The stack and heap represent two fundamental memory regions within Windows processes.

The stack manages function execution and temporary data through structured stack frames, while the heap provides flexible memory allocation for dynamic program data.

Memory allocation APIs allow applications to interact with the Windows memory manager to obtain and release memory resources.

Improper memory management can lead to vulnerabilities such as stack overflows, heap corruption, and use-after-free conditions.

These vulnerabilities form the basis of many exploitation techniques used by attackers.

Understanding stack and heap architecture helps security professionals analyze memory-based attacks, interpret EDR alerts, investigate fileless malware, and understand the mechanics behind modern exploitation strategies.