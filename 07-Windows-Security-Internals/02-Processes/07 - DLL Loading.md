# 07 - DLL Loading

## Overview

Dynamic Link Libraries (DLLs) are a fundamental component of the Windows execution model. Most Windows applications rely heavily on DLLs to access operating system functionality and shared libraries. Rather than containing all code internally, applications dynamically load external modules that provide reusable functionality.

The Windows operating system includes a sophisticated **loader subsystem** responsible for locating, mapping, and initializing these modules within a process. This loading mechanism occurs during process startup and also dynamically during execution.

Understanding how DLL loading works internally is critical from a defensive perspective. Many attack techniques exploit weaknesses in the loading process, particularly the **DLL search order**, to introduce malicious code into trusted processes.

For defenders and SOC analysts, monitoring DLL loading behavior can reveal indicators of compromise such as **DLL hijacking, injection, and persistence mechanisms**.

---

## What Dynamic Link Libraries (DLLs) Are

A **Dynamic Link Library (DLL)** is a Portable Executable (PE) file that contains code and data designed to be shared by multiple programs.

DLLs provide reusable functionality that applications can load during runtime rather than compiling directly into the executable.

Typical capabilities provided by DLLs include:

- Operating system APIs
- Networking functionality
- User interface components
- Cryptographic libraries
- System services

Examples of common Windows DLLs include:

    kernel32.dll
    user32.dll
    advapi32.dll
    ntdll.dll

These libraries implement core operating system functionality used by most applications.

---

## Why Windows Uses DLLs Instead of Static Linking

Windows relies on dynamic linking because it improves efficiency and maintainability across the operating system.

### Code Reuse

Many applications use the same functionality. Instead of duplicating code in every executable, DLLs allow programs to share a single implementation.

### Memory Efficiency

Multiple processes can map the same DLL into memory. Because the code sections are shared, physical memory usage is reduced.

### Simplified Updates

Updating a single DLL can update functionality across many applications without recompiling them.

### Modular System Design

DLLs allow Windows to maintain a modular architecture where components can be independently updated or replaced.

---

## How DLLs Enable Modular Software Architecture

DLLs support a modular design model where applications are composed of multiple independent components.

Example structure:

    Application.exe
        |
        +-- networking.dll
        +-- crypto.dll
        +-- graphics.dll

Each component can be developed and maintained independently.

This modularity is essential for large operating systems like Windows, where thousands of components interact.

---

## Windows Loader Architecture

### Role of the Windows Loader

The **Windows loader** is responsible for preparing an executable and its required modules for execution.

Key responsibilities include:

- Loading the executable into memory
- Resolving imported libraries
- Mapping DLLs into process address space
- Fixing memory relocations
- Calling initialization routines

The loader operates during process creation and also during runtime when applications explicitly request libraries.

---

### The Function of ntdll.dll in Loading Modules

The library **ntdll.dll** contains low-level routines used by the Windows loader.

It acts as the interface between user-mode processes and the Windows kernel.

Important responsibilities include:

- Implementing loader functions
- Providing system call interfaces
- Supporting module management structures

Many internal loader functions begin with the prefix:

    Ldr*

Examples include internal routines that load libraries and manage module lists.

---

### Interaction with the Windows Executive and Memory Manager

The loader interacts with kernel subsystems responsible for memory and object management.

Key interactions include:

**Memory Manager**

Responsible for mapping DLL files into process memory using memory-mapped file mechanisms.

**Windows Executive**

Manages system objects and process structures required for module tracking.

Through these subsystems, DLL files become executable code within a process address space.

---

## DLL Loading Process

The process of loading a DLL involves several internal steps performed by the Windows loader.

### Process Startup and Loader Initialization

When a process starts, the Windows kernel initializes the **Process Environment Block (PEB)**.

The loader then reads the executable's **Import Table**, which lists all required DLL dependencies.

Example import list:

    kernel32.dll
    user32.dll
    advapi32.dll

The loader must locate and load each required module before the application can begin execution.

---

### Resolving Imports

Each DLL may also depend on additional libraries.

The loader recursively resolves these dependencies.

Example:

    Application.exe
        |
        +-- kernel32.dll
               |
               +-- ntdll.dll

The loader builds a complete dependency tree of required modules.

---

### Mapping the DLL into Process Memory

Once the DLL file is located, the Windows Memory Manager maps it into the process address space.

This occurs using **memory-mapped file mechanisms**.

Typical layout:

    Process Memory

    +---------------------+
    | Executable Image    |
    +---------------------+
    | DLL Module 1        |
    +---------------------+
    | DLL Module 2        |
    +---------------------+

Code sections may be shared across processes, while writable sections remain private.

---

### Relocations and Address Fixing

DLLs are typically compiled with a **preferred base address**.

If that address is already occupied in the process memory space, Windows performs **relocation**.

Relocation adjusts internal memory references so the module can execute correctly at a new address.

---

### Executing the DLL Entry Point (DllMain)

After the DLL is mapped and relocations are resolved, the loader executes the module's entry point.

This entry point is typically the function:

    DllMain

The loader calls DllMain with the reason:

    DLL_PROCESS_ATTACH

This allows the DLL to initialize resources when it is loaded into a process.

---

## PEB and the Loader Data Structures

### Role of the Process Environment Block (PEB)

The **Process Environment Block (PEB)** is a data structure stored in process memory that contains important runtime information.

It includes:

- Loader metadata
- Module lists
- Process configuration information

Security tools and attackers often inspect the PEB to enumerate loaded modules.

---

### Loader Structures (PEB_LDR_DATA)

The PEB contains a pointer to a structure called **PEB_LDR_DATA**, which stores lists of loaded modules.

These lists track every DLL loaded into the process.

Typical lists include:

- Load order list
- Memory order list
- Initialization order list

Each entry represents a loaded module.

---

### How Windows Tracks Loaded Modules

When a DLL is loaded, the loader inserts an entry into the module list.

Example structure:

    PEB
        |
        +-- PEB_LDR_DATA
                |
                +-- Module List
                        |
                        +-- kernel32.dll
                        +-- user32.dll
                        +-- advapi32.dll

These lists allow the loader to manage dependencies and prevent duplicate loads.

---

## DLL Search Order

When an application requests a DLL without specifying a full path, Windows follows a **search order** to locate the file.

The default search order includes the following locations.

### Application Directory

The directory containing the executable is searched first.

This allows applications to ship custom DLL versions.

---

### System Directories

Windows searches system library locations such as:

    System32

These directories contain core operating system libraries.

---

### Windows Directory

The main Windows installation directory is also searched.

---

### Current Working Directory

The directory from which the process was launched may be searched.

This location is particularly important for security concerns.

---

### PATH Environment Variable

Finally, Windows searches directories listed in the system PATH environment variable.

These directories often contain application-specific libraries.

---

## Security Risks of DLL Loading

The DLL loading mechanism relies on assumptions about **trusted directories and file placement**.

If those assumptions are violated, attackers may influence which DLL is loaded.

This creates opportunities for code execution inside legitimate processes.

---

### Trust Assumptions in the Loader

The loader assumes that directories in the search order contain trusted libraries.

However, if an attacker can place a malicious DLL in one of these locations, the application may load it automatically.

---

### Manipulating DLL Loading Behavior

Attackers may exploit DLL loading behavior by:

- Placing malicious DLLs in searched directories
- Exploiting missing dependencies
- Modifying application paths

This can cause malicious modules to execute with the privileges of the target process.

---

## DLL Hijacking

### Concept of DLL Search Order Hijacking

DLL hijacking occurs when an attacker places a malicious DLL in a location that is searched before the legitimate library.

If the application loads the malicious DLL first, attacker code executes inside the process.

---

### Missing DLL Abuse

Some applications attempt to load DLLs that do not exist on the system.

Attackers can place a malicious DLL with that name in a searched directory.

When the application attempts to load the missing module, the malicious DLL is executed.

---

### Malicious DLL Placement

Typical attacker strategy:

    1. Identify application loading missing DLL
    2. Create malicious DLL with same name
    3. Place DLL in application directory
    4. Launch application

The malicious DLL loads automatically.

---

## DLL Injection Concepts

Many process injection techniques rely on forcing a process to load a malicious DLL.

---

### LoadLibrary Injection

A common injection technique involves creating a remote thread in a target process that calls:

    LoadLibrary

This forces the process to load an attacker-controlled DLL.

---

### Reflective DLL Loading (Conceptual)

Reflective loading bypasses the normal Windows loader.

Instead of using the operating system loader, the attacker manually maps the DLL into memory and executes it.

This technique avoids many traditional detection methods.

---

### Process Injection via DLLs

Typical injection workflow:

    OpenProcess
        |
        WriteProcessMemory
        |
        CreateRemoteThread
        |
        LoadLibrary

The result is malicious code executing inside the target process.

---

## Detection and SOC Perspective

Defenders can monitor DLL loading behavior to identify suspicious activity.

---

### Monitoring Unusual DLL Loads

Security monitoring tools may track module loads inside processes.

Indicators of concern include:

- DLLs loaded from user-writable directories
- DLLs loaded from temporary locations
- Unexpected modules inside critical processes

---

### Suspicious DLL Locations

Malicious DLLs are often stored in locations such as:

    Temp directories
    User profile folders
    Application directories

These locations should not normally contain system libraries.

---

### Detecting Unsigned or Unexpected Modules

Unsigned DLLs or modules with unusual names can indicate compromise.

Unexpected modules inside sensitive processes may signal injection or hijacking.

---

### Common Investigation Techniques

Security analysts often investigate DLL behavior by:

- Enumerating loaded modules in a process
- Examining module file paths
- Analyzing digital signatures
- Reviewing process creation and module load events

These techniques help identify unauthorized code execution.

---

## Key Takeaways

DLL loading is a fundamental part of the Windows execution environment.

The Windows loader is responsible for locating, mapping, and initializing modules within a process. These modules are tracked through internal data structures such as the Process Environment Block.

Because the loader searches multiple directories when resolving DLL dependencies, the search order can introduce security risks. Attackers exploit this behavior through techniques such as DLL hijacking and malicious module placement.

DLL loading mechanisms are also central to many attack techniques, including:

- process injection
- credential access tools
- persistence mechanisms
- malicious code execution within trusted processes

For defenders and SOC analysts, monitoring module loading behavior is essential for detecting these threats. Abnormal DLL loads, suspicious module locations, and unexpected libraries within processes can provide strong indicators of compromise.

Understanding DLL loading internals therefore provides critical insight into both **Windows execution mechanisms and common attacker techniques**.