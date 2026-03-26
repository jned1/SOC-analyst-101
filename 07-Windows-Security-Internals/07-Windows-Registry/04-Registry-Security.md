# 04-Registry-Security

## Overview

The Windows Registry is a critical component of the operating system that directly influences system behavior, application execution, and security controls. Because of its central role, it is a high-value target for attackers seeking persistence, privilege escalation, and defense evasion.

Securing the Registry is essential to maintaining system integrity and preventing unauthorized modifications.

---

## Importance of Securing the Windows Registry

The Registry stores sensitive configuration data, including:

- System startup behavior
- Service configurations
- Security policies
- User environment settings

Unauthorized changes can lead to:
- Persistent malware execution
- Escalation of privileges
- Disabling of security controls

---

## Registry as a Security Boundary

While the Registry enforces access control, it is not a strict security boundary.

- Access is governed by ACLs and user privileges
- Processes with sufficient rights can modify critical keys
- Misconfigurations can weaken enforcement

Security depends on proper permission management and monitoring.

---

## Registry Access Control

---

### Permissions on Registry Keys

Each registry key has associated permissions that define:

- Who can read the key
- Who can modify or delete values
- Who can create subkeys

Permissions are enforced during every access request.

---

### Security Descriptors

Registry keys contain security descriptors that include:

- Owner SID
- Discretionary Access Control List (DACL)
- System Access Control List (SACL)

These descriptors define both access control and auditing behavior.

---

### Access Control Lists (ACLs)

- DACLs determine allowed and denied access
- SACLs define which operations are logged

Properly configured ACLs are essential to protecting sensitive registry locations.

---

## Auditing and Monitoring

---

### Registry Auditing

- Enabled via SACLs on registry keys
- Allows logging of:
  - Successful access
  - Failed access attempts
  - Modification events

Audit logs are recorded in Windows Security Event Logs.

---

### Tracking Changes to Sensitive Keys

Critical keys to monitor include:

- Autorun locations
- Service configuration keys
- Security-related keys (e.g., policies)

Tracking changes helps detect persistence mechanisms and unauthorized modifications.

---

## Common Security Weaknesses

---

### Weak Permissions

- Overly permissive ACLs (e.g., Everyone: Full Control)
- Allow unauthorized users to modify critical settings

---

### Writable Sensitive Keys

- Keys controlling execution paths or startup behavior
- Writable by low-privileged users

These conditions enable persistence and privilege escalation.

---

### Misconfigured Services Keys

- Service registry entries define executable paths
- If writable:
  - Attackers can modify service binaries
  - Achieve execution with elevated privileges

---

## Attack Surface

---

### Privilege Escalation via Registry

Attackers exploit registry misconfigurations to:
- Modify service paths
- Inject malicious executables
- Gain elevated execution context

---

### Persistence via Registry

Common techniques include:
- Adding entries to Run keys
- Modifying Winlogon values
- Creating malicious services

These ensure execution across reboots and logons.

---

### Configuration Tampering

Attackers may alter registry settings to:
- Disable security tools
- Modify system policies
- Change application behavior

This can weaken defenses and enable further compromise.

---

## Defensive and SOC Perspective

---

### Monitoring Key Modifications

- Track creation, deletion, and modification of registry keys
- Focus on high-risk locations:
  - Startup keys
  - Service configurations
  - Security policies

---

### Detecting Suspicious Registry Writes

Indicators include:
- Writes by unexpected processes
- Changes from low-privileged accounts
- Use of scripting engines or command-line tools

Unusual write activity often signals compromise.

---

### Correlating Registry Activity with Attack Behavior

- Combine registry events with:
  - Process creation logs
  - Command-line arguments
  - User context

Correlation improves detection of complex attack chains.

---

## Mitigation Strategies

---

### Hardening Registry Permissions

- Restrict write access to critical keys
- Remove unnecessary permissions
- Enforce strict ACL configurations

---

### Least Privilege Enforcement

- Limit user and application access rights
- Prevent low-privileged users from modifying sensitive keys

---

### Regular Auditing

- Periodically review registry permissions and configurations
- Identify and remediate misconfigurations
- Validate integrity of critical keys

---

## Key Takeaways

- The Registry is a central component of Windows security and system behavior
- It is a high-value target for attackers seeking persistence and escalation
- Access control is enforced through security descriptors and ACLs
- Weak permissions and writable keys are major security risks
- Monitoring registry activity is essential for detection and response
- Proper hardening and auditing significantly reduce attack surface