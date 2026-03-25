# 03-Persistence-Techniques

## Overview

Persistence in cybersecurity refers to techniques used by attackers to maintain access to a system across reboots, logouts, or service restarts. In Windows environments, the Registry is one of the most commonly abused components for persistence due to its central role in system and application configuration.

Understanding registry-based persistence is critical for detecting long-term compromises and preventing repeated unauthorized access.

---

## What Persistence Means in Cybersecurity

Persistence ensures that an attacker’s access to a system is not lost after:

- System reboot
- User logoff
- Process termination

It allows attackers to:
- Maintain foothold
- Re-execute malicious code
- Avoid repeated exploitation

---

## Why the Registry is Commonly Used for Persistence

The Registry is a preferred persistence mechanism because:

- It is executed automatically during system startup and user logon
- It is trusted by the operating system
- It allows silent configuration changes
- It does not always require dropping visible files

Registry-based persistence is often stealthy and blends with legitimate system behavior.

---

## Common Registry Persistence Locations

---

### Run Keys

Locations:

- HKLM\Software\Microsoft\Windows\CurrentVersion\Run
- HKCU\Software\Microsoft\Windows\CurrentVersion\Run

Behavior:
- Executes specified programs at user logon

Common abuse:
- Adding malicious executables to run automatically

---

### RunOnce Keys

Locations:

- HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce
- HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce

Behavior:
- Executes once at next logon, then deletes itself

Common abuse:
- Temporary persistence or staged execution

---

### Services Registry Keys

Location:

- HKLM\SYSTEM\CurrentControlSet\Services

Behavior:
- Defines system services and drivers
- Services may run with elevated privileges (often SYSTEM)

Common abuse:
- Creating or modifying services to execute malicious binaries

---

### Winlogon Keys

Location:

- HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon

Important values:
- Shell
- Userinit

Behavior:
- Controls processes launched during user logon

Common abuse:
- Replacing or appending malicious executables

---

### Startup-Related Entries

Other relevant locations:

- HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run
- HKLM equivalents for system-wide persistence

Behavior:
- Enforces execution policies at logon

---

## How Registry Persistence Works

---

### Execution at System Startup or User Logon

- The operating system reads specific registry keys during:
  - Boot sequence
  - User authentication

- Any executable referenced in these keys is launched automatically

---

### Linking Executables to Registry Keys

- Attackers add entries that point to:
  - Malicious executables
  - Scripts or command interpreters

Example concept:

  Value Name: Updater  
  Data: C:\Users\Public\malware.exe

This ensures repeated execution without user interaction.

---

## Fileless Persistence

---

### Storing Payload References Without Files

- Registry entries can reference:
  - Encoded commands
  - Script interpreters (e.g., PowerShell)

Example concept:

  powershell -encodedcommand <payload>

---

### Using Registry as Storage

- Malicious payloads may be stored directly in registry values
- Executed by:
  - Scripts retrieving and decoding the data
  - Living-off-the-land binaries

This reduces reliance on files and improves stealth.

---

## Real-World Attack Patterns

---

### Malware Using Run Keys

- Commodity malware frequently adds entries to Run keys
- Ensures execution at every user logon
- Often combined with obfuscated file paths

---

### Registry-Based Backdoors

- Attackers store commands or payloads in registry values
- Use scheduled execution mechanisms to trigger them
- Enables persistent remote access without obvious artifacts

---

## Detection and SOC Perspective

---

### Monitoring Registry Changes

- Track modifications to critical keys:
  - Run and RunOnce
  - Services
  - Winlogon

- Sudden additions or changes are strong indicators of compromise

---

### Identifying Suspicious Autorun Entries

Look for:
- Unknown executables
- Execution from user-writable directories
- Encoded or obfuscated commands

Unusual naming conventions may also indicate malicious intent.

---

### Correlating Registry Activity with Process Execution

- Link registry changes with:
  - Process creation events
  - Command-line arguments
  - User context

Correlation improves detection accuracy and reduces false positives.

---

## Mitigation Strategies

---

### Restricting Write Permissions

- Limit who can modify critical registry keys
- Enforce least privilege for users and applications

---

### Monitoring Critical Keys

- Implement continuous monitoring of:
  - Autorun locations
  - Service configurations
  - Logon-related keys

Use alerting for unauthorized changes.

---

### Endpoint Detection Tools

- Deploy EDR solutions to:
  - Detect registry abuse patterns
  - Identify fileless persistence techniques
  - Correlate registry and process behavior

---

## Key Takeaways

- Persistence ensures attackers maintain access across system events
- The Registry is a primary persistence mechanism in Windows
- Autorun keys, services, and Winlogon are common targets
- Fileless persistence increases stealth and detection difficulty
- Monitoring registry changes is essential for detection
- Restricting access and enforcing least privilege reduces risk