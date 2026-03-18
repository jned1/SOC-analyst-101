# 04-Privilege-Escalation-Concepts

## Overview

Privilege escalation is a fundamental concept in Windows security and a critical phase in post-exploitation. It refers to the process of gaining higher-level permissions than initially granted, typically moving from a low-privileged user context to Administrator or SYSTEM.

Understanding privilege escalation is essential for both attackers and defenders. For attackers, it enables deeper control over a system. For defenders, it is a key point of detection and prevention within an attack chain.

---

## What Privilege Escalation Is

Privilege escalation is the act of exploiting a system flaw, misconfiguration, or design weakness to gain elevated access rights.

This typically involves:
- Expanding access beyond assigned permissions
- Gaining administrative or SYSTEM-level execution
- Accessing restricted resources or sensitive data

---

## Vertical vs Horizontal Escalation

### Vertical Privilege Escalation
- Moving from a lower privilege level to a higher one
- Example: Standard user → Administrator → SYSTEM

### Horizontal Privilege Escalation
- Accessing resources or accounts at the same privilege level
- Example: One user account accessing another user’s data

---

## Why Privilege Escalation is Critical in Attack Chains

Privilege escalation is rarely the initial step. It typically follows initial access and enables:

- Persistence mechanisms
- Credential harvesting
- Lateral movement
- Disabling security controls
- Full system compromise

Without privilege escalation, attackers are often restricted in impact.

---

## Windows Privilege Model Recap

### Users, Groups, and SIDs
- Every user and group is identified by a Security Identifier (SID)
- Access control decisions are based on SIDs, not usernames
- Groups define collections of permissions (e.g., Administrators)

### Access Tokens and Privileges
- Access tokens are attached to processes and contain:
  - User SID
  - Group memberships
  - Privileges (e.g., SeDebugPrivilege)
- Tokens define what actions a process can perform

### Integrity Levels
- Mandatory Integrity Control (MIC) enforces process trust levels:
  - Low
  - Medium
  - High
  - System
- Prevents lower integrity processes from modifying higher ones

### Role of LSASS in Identity
- Local Security Authority Subsystem Service (LSASS) handles:
  - Authentication
  - Token creation
  - Credential storage in memory
- A primary target for credential-based escalation

---

## Common Privilege Escalation Categories

### Misconfigurations
- Incorrect permissions on files, services, or registry
- Most common and widely exploited category

### Credential-Based Escalation
- Leveraging stored or captured credentials
- Includes hashes, tokens, and plaintext secrets

### Token Abuse
- Manipulating access tokens for impersonation or duplication

### Service-Based Escalation
- Exploiting Windows services or scheduled tasks

### Kernel and Driver Exploitation
- Exploiting vulnerabilities in kernel-mode components

---

## Misconfiguration-Based Escalation

### Weak Service Permissions
- Services configured with overly permissive access rights
- Attackers can modify service binaries or configurations

### Unquoted Service Paths
- Service paths with spaces not enclosed in quotes:
  
    C:\Program Files\My App\service.exe

- Windows may execute:
  
    C:\Program.exe

- Allows attackers to place malicious binaries in predictable locations

### Writable Binaries and Directories
- Executable files or directories with write permissions
- Attackers replace or modify binaries to gain execution

### Registry Misconfigurations
- Weak ACLs on registry keys controlling services or startup behavior
- Enables modification of execution paths

---

## Credential and Token Abuse

### Credential Dumping
- Extracting credentials from memory (e.g., LSASS)
- Provides access to privileged accounts

### Pass-the-Hash
- Using NTLM hashes instead of plaintext passwords for authentication

### Token Impersonation
- Using another user’s token to execute actions
- Requires specific privileges (e.g., SeImpersonatePrivilege)

### Access Token Duplication
- Cloning an existing token to spawn a new process with elevated rights

---

## Service and Scheduled Task Abuse

### Modifying Existing Services
- Changing service binary paths or startup configurations

### Creating Malicious Services
- Registering a new service that executes attacker-controlled code

### Scheduled Task Manipulation
- Modifying or creating tasks that run with elevated privileges

---

## Kernel and Driver Exploitation

### Vulnerable Drivers
- Signed drivers with exploitable flaws
- Allow escalation despite driver signing enforcement

### Arbitrary Read/Write Primitives
- Exploits enabling direct kernel memory manipulation

### Ring 0 Privilege Escalation
- Gaining execution in kernel mode (highest privilege level)

---

## UAC Bypass Concepts

### Why UAC is Not a Strict Security Boundary
- Designed for convenience, not strong isolation
- Admin users already possess elevated tokens

### Auto-Elevation Abuse
- Certain binaries automatically elevate without prompting
- Attackers hijack execution paths or DLL loading

### Living-off-the-Land Binaries (LOLBins)
- Legitimate Windows binaries used for malicious purposes
- Common in bypassing UAC and avoiding detection

---

## Attack Flow (Conceptual)

A typical privilege escalation path:

1. Initial access (low privilege)
2. System enumeration
3. Identification of weaknesses:
   - Misconfigurations
   - Credentials
   - Vulnerable components
4. Exploitation of identified weakness
5. Execution with elevated privileges (Administrator or SYSTEM)

---

## Detection and SOC Perspective

### Indicators of Privilege Escalation
- Sudden privilege level changes
- Unexpected access to sensitive resources

### Abnormal Process Behavior
- Unusual command-line arguments
- Execution from non-standard directories

### Suspicious Parent-Child Relationships
- Example:
  
    winword.exe → cmd.exe → powershell.exe

### Service and Registry Modifications
- Changes to service configurations
- Registry key modifications in autorun locations

### Token Anomalies
- Processes running under unexpected user contexts
- Token privilege abuse patterns

---

## Mitigation Strategies

### Least Privilege Enforcement
- Limit user and service permissions to minimum required

### Patch Management
- Regular updates to OS and drivers

### Service Hardening
- Restrict service permissions
- Use secure service configurations

### Credential Protection
- Protect LSASS memory
- Enable Credential Guard where possible

### Monitoring and Logging
- Enable detailed audit policies
- Monitor process creation, privilege use, and authentication events

---

## Key Takeaways

- Privilege escalation is a core step in most attacks
- Most techniques exploit misconfigurations, not zero-day vulnerabilities
- Understanding Windows internals is essential for detecting escalation
- Effective detection relies on behavioral analysis, not signatures alone
