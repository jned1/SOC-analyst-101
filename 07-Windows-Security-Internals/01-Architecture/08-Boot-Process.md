# 08-Boot-Process.md

## Overview

### What the Windows Boot Process Is

The Windows boot process is the ordered sequence of firmware, bootloader, kernel, and user-mode initialization steps that transition a system from powered-off hardware to an authenticated user session.

It establishes:

- Hardware initialization
- Operating system loading
- Kernel trust boundaries
- Driver integrity enforcement
- Security subsystem activation

### Why the Boot Chain Is a Critical Security Boundary

The boot chain defines the root of trust for the entire operating system. Any compromise before or during kernel initialization can:

- Bypass security controls
- Load malicious kernel drivers
- Disable protections such as code integrity
- Achieve stealth persistence below user-mode visibility

If the boot chain is compromised, all higher-layer security controls inherit that compromise.

### Trust Establishment at Startup

Modern Windows systems rely on a chain of trust:

1. Firmware validates bootloader
2. Bootloader validates OS loader
3. OS loader validates kernel and drivers
4. Kernel enforces runtime integrity policies

Each stage validates the next before execution continues.

---

## High-Level Boot Phases

### UEFI/BIOS Initialization

On power-on:

- Firmware initializes CPU, memory, and hardware devices
- UEFI systems read boot configuration from EFI System Partition
- BIOS systems use legacy MBR mechanisms (deprecated in modern deployments)

UEFI firmware loads:

    bootmgfw.efi

from the EFI partition.

Security boundary:
If firmware is modified, Secure Boot protections may be bypassed.

---

### Windows Boot Manager (bootmgr / bootmgfw.efi)

Boot Manager:

- Reads Boot Configuration Data (BCD)
- Displays boot menu (if applicable)
- Selects OS entry
- Loads the Windows OS Loader

BCD store location (UEFI systems):

    \EFI\Microsoft\Boot\BCD

Security implication:
BCD manipulation can alter boot parameters, disable integrity checks, or load alternate kernels.

---

### Windows OS Loader (winload.efi)

winload.efi performs:

- Loading of ntoskrnl.exe
- Loading of HAL (hal.dll)
- Loading of boot-start drivers
- Loading of SYSTEM registry hive

It verifies digital signatures of:

- Kernel image
- Boot drivers

At this stage, code integrity policies begin enforcement.

---

### Kernel Initialization

Control is transferred to:

    ntoskrnl.exe

Kernel initialization includes:

- Memory manager setup
- Process manager initialization
- Security reference monitor initialization
- Object manager creation
- Interrupt handling configuration

Boot-start drivers are initialized in dependency order.

---

### Session Manager (smss.exe) Startup

Once kernel initialization completes:

- Kernel creates initial system process
- smss.exe (Session Manager Subsystem) is launched

smss.exe:

- Creates system sessions
- Initializes paging files
- Launches wininit.exe and winlogon.exe

This marks the transition from kernel-only initialization to user-mode system initialization.

---

## Secure Boot and Code Integrity

### UEFI Secure Boot

Secure Boot ensures that:

- Only signed bootloaders execute
- Firmware verifies digital signatures before execution

If Secure Boot is enabled:

- Unsigned or tampered boot components are blocked
- Rootkits modifying bootloaders are prevented

Disabling Secure Boot weakens root-of-trust enforcement.

---

### Driver Signature Enforcement

Windows requires signed kernel-mode drivers.

Driver types affected:

- Boot-start drivers
- System-start drivers
- Runtime-loaded drivers

Unsigned drivers are blocked unless enforcement is disabled.

---

### Kernel Mode Code Signing (KMCS)

KMCS enforces:

- Cryptographic signature validation for kernel modules
- Prevention of arbitrary kernel code execution

Compromised signing certificates represent a high-risk threat.

---

### Early Launch Anti-Malware (ELAM)

ELAM drivers load before other third-party drivers.

Purpose:

- Classify boot drivers as trusted, suspicious, or malicious
- Prevent known-malicious drivers from initializing

ELAM operates before most attack surface becomes available.

---

## Kernel Initialization Phase

### Loading ntoskrnl.exe

ntoskrnl.exe contains:

- Scheduler
- Memory manager
- I/O manager
- Security reference monitor

It becomes the highest-privileged execution environment (Ring 0).

---

### HAL Initialization

The Hardware Abstraction Layer:

    hal.dll

Provides:

- Hardware-independent interfaces
- Interrupt routing
- Low-level hardware management

HAL ensures portability across hardware platforms.

---

### Driver Loading Sequence

Driver load order:

1. Boot-start drivers
2. System-start drivers
3. Automatic-start services (after SCM)

Driver configuration retrieved from:

    HKLM\SYSTEM\CurrentControlSet\Services

Malicious boot drivers can gain execution before security controls are fully active.

---

### Registry SYSTEM Hive Usage

The SYSTEM hive contains:

- Service definitions
- Driver load order
- Control sets

Control set selection occurs early in boot.

Registry tampering can redirect driver paths or alter start types.

---

## Service and User Mode Initialization

### smss.exe

Session Manager:

- Creates Session 0
- Initializes subsystem processes
- Executes pending file rename operations

Critical for system stability and trust continuation.

---

### wininit.exe

Launched by smss.exe.

Starts:

- services.exe
- lsass.exe

---

### services.exe

Service Control Manager:

- Starts auto-start services
- Manages background service lifecycle

Represents a major persistence and privilege boundary.

---

### lsass.exe

Local Security Authority Subsystem Service:

- Enforces authentication
- Manages security policies
- Issues access tokens

Compromise results in credential theft and privilege abuse.

---

### winlogon.exe

Responsible for:

- Interactive logon
- Credential provider interaction
- Secure attention sequence handling

Marks transition to authenticated user session.

---

## Security Implications

### Bootkits and Rootkits

Bootkits modify:

- Bootloader
- EFI components
- Early drivers

They execute before the OS fully initializes, evading traditional detection.

Kernel rootkits may:

- Patch kernel structures
- Hide processes
- Manipulate system calls

---

### Malicious Driver Persistence

Attackers install drivers configured as:

    Start = 0 (Boot)
    Start = 1 (System)

This ensures early execution at startup.

---

### Disabling Secure Boot

Attackers with firmware or administrative access may:

- Disable Secure Boot
- Enroll malicious keys
- Modify boot variables

This breaks the root-of-trust model.

---

### Manipulating Boot Configuration (BCD Abuse)

Attackers may modify BCD to:

- Enable test signing
- Disable integrity checks
- Force alternate kernel loading

This weakens driver enforcement and security validation.

---

### Impact of Compromised Boot Chain

If boot trust is compromised:

- Kernel protections are unreliable
- Security tools may be blinded
- Persistence survives OS reinstallation (in firmware-level compromise)

Boot-level compromise represents maximum attacker control.

---

## Attack Techniques Targeting Boot

### Bootloader Tampering

Modification of:

- bootmgfw.efi
- winload.efi

Allows arbitrary pre-kernel code execution.

---

### Unsigned Driver Loading

Attackers attempt to:

- Disable signature enforcement
- Exploit vulnerable signed drivers
- Load malicious kernel modules

Signed vulnerable drivers are often abused for kernel memory access.

---

### Early Kernel Code Execution

Malicious boot drivers execute before:

- Endpoint security tools
- EDR drivers
- User-mode monitoring agents

This allows stealth manipulation of kernel structures.

---

### Bypass of Secure Boot Protections (Conceptual)

Conceptual methods include:

- Firmware vulnerabilities
- Misconfigured Secure Boot policies
- Compromised signing keys

Successful bypass breaks the entire trust chain.

---

## Defensive and SOC Perspective

### Monitoring Driver Load Events

Monitor:

- Kernel driver load events
- Unexpected boot-start drivers
- Drivers loaded from non-standard paths

Correlate with:

- Recent registry changes
- Service modifications

---

### Detecting Changes in Boot Configuration

Monitor:

- BCD modifications
- Secure Boot state changes
- Test signing mode activation

Unexpected integrity policy changes are high severity.

---

### Secure Boot Validation Checks

Validate periodically:

- Secure Boot enabled status
- Firmware integrity
- Platform configuration registers (in enterprise environments)

---

### Event Logs Related to Boot Integrity

Relevant telemetry includes:

- Kernel driver load events
- Code integrity failures
- Service start failures
- Early boot security warnings

Absence of expected security driver loads may also indicate tampering.

---

### Why Boot-Level Compromise Is Difficult to Detect

- Occurs before logging infrastructure is active
- Executes at highest privilege
- Can tamper with kernel structures directly
- May hide from user-mode detection tools

Detection often requires:

- Offline forensic analysis
- Memory inspection
- Secure boot attestation mechanisms

---

## Key Takeaways

- The boot process establishes the root of trust for Windows.
- Each stage validates the next, forming a cryptographic trust chain.
- Early-stage compromise results in the highest form of persistence.
- Bootkits and malicious drivers operate before most defenses initialize.
- Monitoring driver loads and boot configuration changes is critical.
- Understanding the boot process enables defenders to detect rootkits, driver abuse, trust chain violations, and stealth persistence.

Mastery of the Windows boot architecture allows security professionals to understand where trust begins, how attackers attempt to break it, and how SOC workflows must adapt to detect compromise at the earliest possible stage.