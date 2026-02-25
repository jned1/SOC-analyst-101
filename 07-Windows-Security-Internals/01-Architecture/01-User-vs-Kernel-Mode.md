# 01-User-vs-Kernel-Mode.md

## Overview

Modern Windows operating systems, including :contentReference[oaicite:0]{index=0}, implement a strict separation between **User Mode** and **Kernel Mode** to enforce security boundaries and maintain system stability.  

This architectural division is fundamental to:

- Preventing unauthorized memory access  
- Enforcing privilege separation  
- Reducing attack surface  
- Containing application crashes  
- Protecting critical operating system components  

Understanding this boundary is essential for analyzing privilege escalation, credential theft, driver abuse, and kernel-level exploitation.

---

## What User Mode and Kernel Mode Are

Windows operates using CPU privilege levels defined by the processor architecture.

- **User Mode** runs with restricted privileges.
- **Kernel Mode** runs with full system privileges.

Code running in Kernel Mode can:

- Access any memory region
- Execute privileged CPU instructions
- Interact directly with hardware

Code running in User Mode:

- Cannot access kernel memory
- Cannot execute privileged instructions
- Must request services from the kernel via system calls

This separation is enforced by hardware and cannot be bypassed without exploiting a vulnerability.

---

## Why Windows Separates Them

The separation exists to enforce:

- Fault isolation  
- Privilege isolation  
- Hardware protection  
- Controlled access to sensitive resources  

If every process had kernel privileges, any application bug would crash the entire system or compromise all data. By isolating user applications, Windows ensures that failures remain contained.

From a security standpoint, this boundary prevents:

- Direct credential extraction from protected memory  
- Arbitrary modification of kernel structures  
- Unauthorized hardware manipulation  

---

## The Concept of Protection Rings (Ring 3 vs Ring 0)

Modern CPUs implement hierarchical privilege levels known as protection rings.

- **Ring 0** → Highest privilege (Kernel Mode)
- **Ring 3** → Lowest privilege (User Mode)

Windows primarily uses:

- Ring 0 for kernel and drivers  
- Ring 3 for applications  

When code attempts to execute a privileged instruction from Ring 3, the CPU blocks it and raises an exception. This hardware-level enforcement is what makes privilege escalation necessary for deeper compromise.

---

## User Mode Explained

### What Runs in User Mode

User Mode includes:

- User applications (browsers, editors, security tools)
- Services
- The Win32 subsystem
- Security processes such as :contentReference[oaicite:1]{index=1} (Local Security Authority Subsystem Service)

Each process runs in its own virtual address space.

---

### Process Isolation

Every process has:

- Its own virtual memory space  
- Restricted access tokens  
- Isolated execution context  

A User Mode process cannot read or write another process's memory without proper privileges.

This prevents direct credential theft unless:

- The attacker gains elevated privileges  
- A vulnerability is exploited  
- Debug privileges are abused  

---

### Access Restrictions

User Mode code cannot:

- Load arbitrary kernel drivers  
- Access physical memory directly  
- Modify kernel objects  
- Execute privileged CPU instructions  

Access to sensitive objects is mediated through the Windows Object Manager and access tokens.

---

### Interaction with Win32 Subsystem

User applications call high-level APIs such as:

    CreateFile()
    OpenProcess()
    VirtualAlloc()

These APIs transition into kernel services via system calls. The Win32 subsystem acts as a controlled interface layer between applications and the kernel.

---

### Security Benefits and Limitations

Benefits:

- Containment of application crashes  
- Reduced impact of exploited applications  
- Memory protection enforcement  

Limitations:

- Vulnerable applications can still escalate privileges  
- Misconfigured services may allow lateral abuse  
- Debug privileges can weaken isolation  

---

## Kernel Mode Explained

### Windows Kernel and Executive

The Windows kernel includes:

- The Kernel (low-level scheduling and interrupts)
- The Executive (memory manager, object manager, security reference monitor)

The Security Reference Monitor enforces access checks based on tokens.

---

### Device Drivers

Drivers operate in Kernel Mode and extend OS functionality.

They:

- Interact with hardware  
- Handle I/O requests  
- Run with full Ring 0 privileges  

A vulnerable driver effectively grants attackers kernel execution.

---

### Full Hardware Access

Kernel Mode allows:

- Direct access to hardware registers  
- Physical memory manipulation  
- Control over CPU scheduling  

This level of access bypasses nearly all OS-level restrictions.

---

### System-Wide Memory Access

Kernel code can:

- Read/write any process memory  
- Modify token privileges  
- Patch kernel structures  

This is why kernel compromise results in total system compromise.

---

### Why Bugs Here Are Critical

A bug in User Mode may crash one application.

A bug in Kernel Mode may:

- Crash the entire system (Blue Screen)
- Allow arbitrary code execution
- Disable security mechanisms
- Steal credentials directly from protected memory

Kernel vulnerabilities are therefore high-severity targets.

---

## System Call Mechanism

### How User Mode Transitions to Kernel Mode

User applications request privileged operations through system calls.

Flow:

User Application  
→ Win32 API  
→ Native API  
→ System Call  
→ Kernel Dispatcher  
→ Kernel Routine  

The CPU switches from Ring 3 to Ring 0 during this transition.

---

### Syscalls and API Flow

Example conceptual flow:

    OpenProcess()
      → NtOpenProcess()
        → sysenter/syscall instruction
          → Kernel handler

This transition is tightly controlled and validated.

---

### Security Implications of System Call Abuse

Attackers may:

- Invoke undocumented syscalls  
- Manipulate syscall parameters  
- Hook system call tables (requires kernel access)  

Abusing system calls can enable:

- Privilege escalation  
- Process injection  
- Token theft  

However, such abuse still requires bypassing access checks.

---

## Security Boundaries and Attack Surface

### Why Kernel Exploits Are Severe

Kernel exploitation breaks the fundamental isolation boundary between User Mode and Kernel Mode.

Once Ring 0 execution is achieved:

- Security controls can be disabled  
- Protected processes can be accessed  
- Credential stores can be dumped  

---

### Privilege Escalation from User to Kernel

Common paths:

- Exploiting vulnerable drivers  
- Kernel memory corruption  
- Improper access validation  

This transforms a limited User Mode compromise into full system control.

---

### Driver Vulnerabilities

Attackers frequently abuse:

- Signed but vulnerable drivers  
- Misconfigured device access controls  
- IOCTL handlers lacking validation  

Driver exploitation is one of the most common real-world privilege escalation techniques.

---

### Token Manipulation Risks

In Kernel Mode, attackers can:

- Replace process tokens  
- Grant SYSTEM privileges  
- Modify security descriptors  

This enables persistent privilege escalation.

---

### Real-World Attack Patterns (Conceptual)

Common patterns include:

- Exploit browser (User Mode)  
- Gain local foothold  
- Escalate via vulnerable driver  
- Dump credentials from LSASS  
- Disable endpoint protections  

Each step aims to cross the User/Kernel boundary.

---

## Defensive Perspective for SOC Analysts

### Indicators of Kernel-Level Compromise

- Unexpected SYSTEM-level processes  
- Security tools being disabled  
- Abnormal token privileges  

---

### Suspicious Driver Loading

Monitor for:

- Newly installed drivers  
- Unsigned or rare drivers  
- Drivers loaded outside normal update cycles  

Driver loading events are critical detection points.

---

### Abnormal Privilege Behavior

Look for:

- SeDebugPrivilege abuse  
- SYSTEM token duplication  
- Rapid privilege escalation after exploitation  

These behaviors often precede credential dumping.

---

### Monitoring Considerations

Focus on:

- Driver load telemetry  
- Privilege assignment changes  
- Process-to-driver interactions  
- Security control tampering  

Kernel compromise often attempts to hide traces by modifying logging mechanisms.

---

## Key Takeaways

- Windows enforces security through strict User Mode and Kernel Mode separation.  
- Ring 3 is restricted; Ring 0 has full system control.  
- Privilege escalation aims to cross this boundary.  
- Kernel exploits enable credential dumping and security bypass.  
- Vulnerable drivers are a major attack vector.  
- Detection must focus on abnormal privilege changes and driver activity.  

The User/Kernel boundary is the core security boundary of Windows. Defenders must understand how it works to recognize when attackers attempt to break it.