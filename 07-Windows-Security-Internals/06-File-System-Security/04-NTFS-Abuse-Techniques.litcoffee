# 04-NTFS-Abuse-Techniques

## Overview

NTFS provides advanced functionality and security features, but its flexibility also introduces multiple attack surfaces. Misconfigurations, weak permissions, and lesser-known features can be abused by attackers to gain persistence, escalate privileges, or evade detection.

Understanding NTFS abuse techniques is critical for identifying real-world attack patterns and implementing effective defensive controls.

---

## Why NTFS is a Common Attack Surface

NTFS is widely targeted because:

- It enforces access control at the file and directory level
- It supports complex permission models that are often misconfigured
- It includes advanced features such as Alternate Data Streams (ADS)
- It is deeply integrated with Windows services and execution paths

Attackers frequently exploit misconfigurations rather than vulnerabilities.

---

## Common NTFS Abuse Techniques

---

### Weak File Permissions

- Files or directories with overly permissive ACLs
- Examples:
  - Everyone: Full Control
  - Authenticated Users: Modify

Impact:
- Unauthorized modification of critical files
- Execution of malicious code

---

### Writable System Directories

- Directories used by services or applications with write access for low-privileged users
- Attackers can:
  - Drop malicious executables
  - Replace legitimate binaries

Common targets include application install paths and service directories.

---

### DLL Hijacking

- Applications load DLLs from predictable locations
- If a directory in the search path is writable:
  - Attackers can place a malicious DLL
  - Application loads attacker-controlled code

This technique relies on Windows DLL search order behavior.

---

### Alternate Data Streams (ADS)

- NTFS supports multiple data streams per file
- Attackers use ADS to:
  - Hide malicious payloads
  - Store data without altering visible file content

Example concept:
  
  legitimate.txt:payload.exe

ADS is not visible in standard directory listings.

---

### File Replacement Attacks

- Replacing legitimate executables or scripts with malicious versions
- Requires write access to the file location

Common targets:
- Service binaries
- Scheduled task executables
- Startup scripts

---

## Persistence Techniques

---

### Using Hidden Files

- Files marked with hidden or system attributes
- Used to avoid casual detection

Attackers often combine this with obscure directory locations.

---

### ADS for Stealth Storage

- Store payloads or scripts inside alternate streams
- Execute using specific techniques without exposing files

ADS provides stealth without requiring additional files on disk.

---

## Privilege Escalation via NTFS

---

### Exploiting Misconfigured Permissions

- Writable files used by privileged processes
- Attackers modify these files to inject malicious code

Examples:
- Logon scripts
- Service configuration files

---

### Service Binary Replacement

- Services running as SYSTEM rely on executable paths
- If these binaries are writable:
  - Replace with malicious executable
  - Restart service to execute with elevated privileges

This is a common and reliable escalation technique.

---

## Detection and SOC Perspective

---

### Monitoring File Changes

- Track:
  - File creation
  - File modification
  - Permission changes

Focus on sensitive directories such as:
- System directories
- Application paths
- Service-related locations

---

### Detecting Suspicious File Paths

- Execution from:
  - Temporary directories
  - User-writable locations
  - Unusual subdirectories

Uncommon execution paths often indicate malicious activity.

---

### Identifying Hidden or Alternate Streams

- Detect files with:
  - Hidden or system attributes
  - Alternate Data Streams

Indicators:
- Unexpected file size discrepancies
- Tools revealing multiple streams

ADS usage is uncommon in legitimate scenarios and should be investigated.

---

## Mitigation Strategies

---

### Proper Permission Management

- Restrict write access to critical directories
- Avoid broad permissions such as Everyone: Full Control
- Regularly audit ACL configurations

---

### File Integrity Monitoring

- Monitor critical files for unauthorized changes
- Detect:
  - Hash changes
  - Unexpected modifications

This is essential for detecting file replacement attacks.

---

### Least Privilege Enforcement

- Ensure users and services operate with minimal required permissions
- Limit write access to only necessary locations

Reduces the attack surface significantly.

---

## Key Takeaways

- NTFS is a major attack surface due to its flexibility and complexity
- Most abuse techniques rely on misconfigurations, not exploits
- Alternate Data Streams provide stealth capabilities for attackers
- Writable directories and weak permissions are high-risk conditions
- Monitoring file activity and enforcing least privilege are critical defenses