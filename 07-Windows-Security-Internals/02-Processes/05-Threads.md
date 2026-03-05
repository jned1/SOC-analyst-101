# 05-Threads.md

## Overview

### What a Thread Is in Windows

A thread is the smallest unit of execution scheduled by the Windows operating system. It represents a sequence of instructions that the CPU executes within the context of a process.

Every running application in Windows operates through threads. A process itself does not execute instructions directly; instead, it acts as a container that holds one or more threads responsible for executing code.

A thread provides the runtime environment necessary for code execution, including:

- CPU register state
- Execution stack
- Scheduling metadata
- Thread-specific data structures

Without at least one thread, a process cannot run any code.

---

### Relationship Between a Process and Its Threads

A process provides the execution environment:

- Virtual address space
- Security context (access token)
- Loaded modules
- Handles and system resources

Threads operate within this environment.

Multiple threads inside the same process:

- Share the same memory space
- Share the same loaded modules
- Share the same security token

However, each thread maintains its own:

- Execution state
- Stack
- CPU registers
- Scheduling context

Because threads share memory, they enable efficient parallel execution but also introduce synchronization challenges and potential security risks.

---

## Thread Architecture in Windows

### Thread Execution Context

The execution context of a thread represents the complete CPU state required to resume execution. It includes the location in code where the thread is currently running and the values stored in CPU registers.

The operating system saves and restores this context during thread scheduling.

---

### Program Counter / Instruction Pointer

The instruction pointer identifies the current instruction being executed by the CPU.

On x64 systems this is stored in the RIP register.

This value determines where execution continues when the thread is resumed.

Attackers sometimes manipulate the instruction pointer to redirect execution to malicious code.

---

### CPU Registers

Registers store temporary data used during execution, including:

- General purpose registers
- Stack pointer
- Instruction pointer
- Flags register

When the scheduler switches between threads, it saves the current register state and restores another thread's register state.

---

### Stack Usage

Each thread maintains its own stack.

The stack stores:

- Function parameters
- Local variables
- Return addresses
- Exception handling data

Stacks grow and shrink as functions are called and returned.

Stack manipulation vulnerabilities can lead to exploitation and code execution.

---

### Thread Environment Block (TEB)

Each thread contains a Thread Environment Block (TEB) located in user-mode memory.

The TEB stores thread-specific information such as:

- Thread-local storage (TLS)
- Exception handling structures
- Pointer to the Process Environment Block (PEB)
- Thread ID
- Stack boundaries

Applications and runtime libraries rely on the TEB to manage per-thread state.

---

### Kernel Thread Structures

In kernel memory, threads are represented by internal structures including:

- ETHREAD
- KTHREAD

These structures store scheduling information, execution state, and kernel-level thread metadata.

The scheduler uses these structures to determine which thread should execute next.

---

### Thread Scheduling

Windows schedules threads rather than processes.

The scheduler determines which thread runs on a CPU core based on:

- Priority
- Scheduling policies
- CPU availability
- Wait states

Because scheduling operates at the thread level, multiple threads from different processes may execute concurrently across CPU cores.

---

## Thread Lifecycle

### Thread Creation

A thread is created when a process requests the operating system to start a new execution path.

During creation, Windows:

- Allocates kernel thread structures
- Initializes the TEB
- Allocates a stack
- Assigns scheduling parameters
- Sets the initial instruction pointer

The thread then enters the ready state.

---

### Ready State

In the ready state, a thread is prepared to execute but is waiting for CPU time.

The scheduler maintains a queue of ready threads ordered by priority.

---

### Running State

A thread enters the running state when the scheduler assigns it to a CPU.

Only one thread per CPU core can run at a time.

During execution, the thread consumes CPU cycles until:

- It finishes execution
- Its time slice expires
- It enters a waiting state

---

### Waiting / Blocked State

Threads often wait for external events such as:

- Disk I/O completion
- Network responses
- Synchronization objects

While waiting, the thread does not consume CPU time.

Once the event completes, the thread returns to the ready state.

---

### Termination

When a thread finishes execution or is explicitly terminated:

- Kernel resources are released
- The thread exits the scheduler
- Its stack and TEB are cleaned up

Improper thread termination can leave artifacts useful during forensic analysis.

---

## Thread Creation Mechanisms

### CreateThread

CreateThread is the standard Windows API used by applications to create a new thread within the same process.

The API:

- Allocates a new stack
- Initializes thread context
- Registers the thread with the scheduler

The kernel ultimately performs the actual thread creation.

---

### CreateRemoteThread

CreateRemoteThread allows a thread to be created inside another process.

The calling process must possess appropriate permissions such as:

PROCESS_CREATE_THREAD

This API is frequently abused by attackers to inject malicious code into legitimate processes.

---

### RtlCreateUserThread

RtlCreateUserThread is a lower-level native API used internally by Windows and occasionally by advanced software.

It interacts more directly with the Windows Native API layer.

Malware sometimes uses this function to bypass monitoring focused on higher-level APIs.

---

### Thread Pools

Modern Windows applications often use thread pools.

Thread pools:

- Maintain reusable worker threads
- Improve performance by avoiding repeated thread creation
- Manage concurrent tasks efficiently

Thread pool mechanisms are heavily used in server applications and system services.

---

## Multithreading and Concurrency

### Why Applications Use Multiple Threads

Multithreading improves application performance and responsiveness.

Common uses include:

Parallel execution  
Background processing  
User interface responsiveness

For example, a web browser may run:

- Rendering threads
- Network threads
- UI threads
- JavaScript execution threads

---

### Synchronization

Threads sharing memory must coordinate access to shared resources.

Windows provides synchronization primitives such as:

- Mutexes
- Semaphores
- Critical sections
- Events

Improper synchronization can lead to unstable application behavior.

---

### Race Conditions

Race conditions occur when multiple threads access shared data simultaneously without proper synchronization.

This can produce unpredictable outcomes.

Race conditions have historically resulted in security vulnerabilities.

---

### Resource Contention

When multiple threads compete for the same resource, contention occurs.

This can degrade performance and create timing-related bugs.

Attackers sometimes exploit timing issues for privilege escalation or information disclosure.

---

## Security Implications of Threads

### Threads in Security Investigations

Threads are critical to understanding runtime behavior.

Malicious code frequently executes inside legitimate processes by creating or hijacking threads.

Because threads run within the process context, they inherit the process's privileges and security identity.

---

### Remote Thread Creation

Remote thread creation is a classic process injection technique.

Attackers:

1. Write malicious code into a target process
2. Create a thread to execute that code

The target process then runs attacker-controlled instructions.

---

### Thread Hijacking

Instead of creating a new thread, attackers may hijack an existing one by modifying its execution context.

This technique reduces suspicious API usage and helps evade detection.

---

### Thread-Based Code Execution

Once a malicious thread begins executing inside a trusted process:

- The process identity masks the malicious activity
- Security monitoring tools may misattribute behavior
- Network activity appears to originate from a trusted application

This technique is widely used in malware and post-exploitation frameworks.

---

## Thread Injection Concepts

### CreateRemoteThread Injection

One of the most widely known injection techniques involves:

1. Allocating memory in a remote process
2. Writing malicious code
3. Creating a remote thread that executes the payload

The new thread begins executing at the injected memory location.

---

### APC Injection

Asynchronous Procedure Calls (APCs) allow code to be queued for execution inside another thread.

Attackers can insert malicious functions into a thread's APC queue.

When the thread enters an alertable state, the queued code executes.

---

### Thread Context Manipulation

Attackers can suspend a thread and modify its execution context.

By changing the instruction pointer, execution is redirected to attacker-controlled code.

This technique is used in several stealth injection methods.

---

### Why These Techniques Hide Activity

Thread injection allows attackers to:

- Execute code inside trusted processes
- Avoid launching new suspicious processes
- Blend malicious activity with legitimate application behavior

As a result, process-based detection alone is insufficient.

---

## Detection and SOC Perspective

### Monitoring Suspicious Thread Creation

Security tools often track:

- Remote thread creation events
- Threads starting from non-module memory regions
- Threads executing from writable memory

These patterns often indicate injection.

---

### Unusual Parent-Child Process Behavior

Thread-based injection frequently accompanies suspicious process relationships.

Examples include:

- Office applications spawning scripting engines
- Browser processes hosting unexpected execution paths

Thread behavior must be correlated with process lineage.

---

### Threads Starting From Unusual Memory Regions

Legitimate threads usually start execution from known module addresses.

Suspicious indicators include:

- Threads starting in heap memory
- Execution from memory pages marked as writable and executable

These conditions strongly indicate code injection.

---

### Correlation With Process Injection Indicators

Thread activity must be analyzed alongside:

- Memory allocation events
- WriteProcessMemory operations
- Handle access to remote processes

Combined analysis reveals injection workflows.

---

### Importance for EDR and Memory Forensics

Advanced security tools inspect:

- Thread start addresses
- Execution stacks
- Loaded module relationships

Memory forensics frequently reveals hidden threads executing malicious payloads inside trusted processes.

Thread-level visibility is essential for detecting modern endpoint attacks.

---

## Key Takeaways

Threads are the fundamental execution units in Windows systems.

Processes provide the execution environment, but threads perform the actual work.

Key concepts include:

- Each process contains one or more threads
- Threads maintain their own execution context and stack
- The Windows scheduler operates at the thread level

From a security perspective:

- Many attacks execute malicious code through injected threads
- Remote thread creation enables process injection
- Thread hijacking can redirect legitimate execution paths
- Malicious threads often run inside trusted processes

For defenders:

- Monitoring thread creation is critical
- Identifying unusual thread start addresses can reveal injection
- Thread analysis strengthens process-based detection strategies
- Memory forensics frequently uncovers hidden malicious threads

Understanding thread internals helps security analysts link low-level execution behavior to higher-level attack techniques, improving detection accuracy and investigative capability.