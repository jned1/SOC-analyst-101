# 02-ACLs-and-Permissions

## Overview

Access Control Lists (ACLs) are a core component of the Windows security model. They define which users and groups can access specific system objects such as files, directories, registry keys, and processes. Proper understanding of ACLs is essential for enforcing least privilege, preventing unauthorized access, and detecting security misconfigurations.

---

## What ACLs Are

An Access Control List (ACL) is a list of rules associated with an object that specifies allowed or denied actions for users or groups.

Each secured object in Windows contains a security descriptor, which includes:
- Owner information
- Access Control Lists (ACLs)

ACLs determine how access decisions are made by the operating system.

---

## Role in Windows Security

ACLs are enforced by the Windows Security Reference Monitor during access checks.

They are responsible for:
- Enforcing authorization decisions
- Restricting access to sensitive resources
- Supporting least privilege principles
- Enabling auditing of access attempts

Without ACLs, Windows would not be able to enforce fine-grained security controls.

---

## Types of ACLs

There are two primary types of ACLs in Windows:

---

### DACL (Discretionary Access Control List)

- Defines who is allowed or denied access to an object
- Contains Access Control Entries (ACEs)
- Evaluated during every access request

If no DACL is present, full access may be granted (depending on context), which is a significant security risk.

---

### SACL (System Access Control List)

- Defines what access attempts should be audited
- Used for logging success and/or failure events
- Integrated with Windows Event Logging

SACLs are essential for monitoring and incident detection.

---

## Access Control Entries (ACEs)

### Structure

Each ACL is composed of multiple ACEs. Each ACE contains:
- Security Identifier (SID) of a user or group
- Access mask (permissions)
- Type (Allow or Deny)
- Flags (inheritance and auditing behavior)

---

### Allow vs Deny

- Allow ACE: Grants specific permissions
- Deny ACE: Explicitly blocks permissions

Deny entries take precedence over Allow entries in most scenarios, making them critical in access evaluation.

---

## Permission Types

Windows defines several standard permission levels:

### Read
- View file contents and attributes

### Write
- Modify file contents and attributes

### Execute
- Run executable files or traverse directories

### Full Control
- Complete access, including:
  - Read, Write, Execute
  - Modify permissions
  - Take ownership

Permissions can be combined and customized based on requirements.

---

## Permission Evaluation Logic

Windows follows a strict process when evaluating access requests.

---

### Order of Evaluation

1. Collect all relevant ACEs from the object's DACL
2. Evaluate Deny ACEs first
3. Evaluate Allow ACEs
4. Determine final access decision

If any Deny ACE explicitly blocks access, the request is denied regardless of Allow entries.

---

### Explicit vs Inherited Permissions

- Explicit permissions:
  - Directly assigned to the object
  - Higher priority

- Inherited permissions:
  - Passed down from parent objects
  - Simplify management but can introduce risks

Inheritance can be blocked or modified at the object level.

---

## Security Implications

---

### Misconfigured ACLs

Common issues include:
- Overly permissive access (e.g., Everyone: Full Control)
- Incorrect inheritance settings
- Missing Deny rules where required

Misconfigurations often lead to unauthorized access or data exposure.

---

### Privilege Escalation Risks

Weak ACLs can enable attackers to:
- Modify executable files or scripts
- Replace service binaries
- Write to sensitive directories

These weaknesses are frequently exploited for privilege escalation.

---

## SOC Perspective

---

### Monitoring Access Violations

- Failed access attempts may indicate:
  - Brute-force access attempts
  - Unauthorized probing of sensitive files

- Relevant events can be captured via auditing policies

---

### Auditing File Access

- SACLs enable detailed logging of:
  - File reads
  - File modifications
  - Permission changes

- Logs are stored in Windows Security Event Logs

Effective monitoring helps detect insider threats and attacker activity.

---

## Key Takeaways

- ACLs are fundamental to Windows access control and authorization
- DACLs control access, while SACLs enable auditing
- ACEs define specific permissions for users and groups
- Deny rules take precedence and must be carefully managed
- Misconfigured ACLs are a common cause of security vulnerabilities
- Monitoring ACL activity is critical for detection and response