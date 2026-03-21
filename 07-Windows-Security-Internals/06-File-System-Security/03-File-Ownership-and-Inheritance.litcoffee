# 03-File-Ownership-and-Inheritance

## Overview

File ownership and permission inheritance are fundamental components of the Windows security model. They determine who controls an object and how permissions are distributed across the filesystem. Mismanagement of these mechanisms can lead to unauthorized access, privilege escalation, and security policy bypass.

---

## Concept of File Ownership in Windows

Every securable object in Windows, including files and directories, has an assigned owner identified by a Security Identifier (SID).

The owner is typically:
- The user who created the object
- A privileged account such as Administrators

Ownership is stored within the object's security descriptor.

---

## Why Ownership Matters

Ownership is critical because it determines who has ultimate control over an object.

Key reasons:
- The owner can modify permissions regardless of current ACL settings
- Ownership overrides restrictive access control configurations
- It is a control point for administrative authority

Even if access is denied via ACLs, the owner retains the ability to reconfigure permissions.

---

## File Ownership

### Owner Rights

The owner of a file or directory has implicit rights to:
- Modify the object's DACL (permissions)
- Assign access to other users or groups
- Change inheritance settings

This makes ownership a powerful control mechanism.

---

### Ability to Modify Permissions

- Owners can grant themselves full access if needed
- They can remove restrictive entries from ACLs
- This capability is enforced by the operating system, not by existing permissions

This behavior ensures recoverability but introduces security risks if abused.

---

## Permission Inheritance

Permission inheritance allows objects to automatically receive permissions from their parent directory.

---

### How Permissions Propagate

- When a file or directory is created, it inherits permissions from its parent
- Inherited permissions are copied as ACEs into the child object
- This simplifies permission management across large directory structures

---

### Parent-Child Relationships

- Directories act as parents
- Files and subdirectories are children
- Changes in parent permissions can propagate downward

This hierarchical model enables centralized control but requires careful configuration.

---

## Inheritance Types

---

### Explicit vs Inherited Permissions

- Explicit permissions:
  - Directly assigned to an object
  - Take precedence over inherited permissions

- Inherited permissions:
  - Derived from parent objects
  - Easier to manage at scale

Windows combines both types when evaluating access.

---

### Blocking Inheritance

Inheritance can be disabled on an object:

- Inherited permissions are either:
  - Converted into explicit permissions, or
  - Removed entirely

Blocking inheritance allows customization but increases complexity and risk.

---

## Security Implications

---

### Ownership Abuse

Attackers can exploit ownership to:
- Take control of files they should not access
- Modify permissions to grant themselves elevated rights
- Bypass existing security controls

This is particularly dangerous when combined with weak privilege assignments.

---

### Privilege Escalation via Ownership

If an attacker gains the ability to take ownership of sensitive objects:
- They can rewrite ACLs
- Gain full control over critical files
- Execute malicious code with elevated privileges

This is a common post-exploitation technique.

---

### Breaking Inheritance Risks

Disabling inheritance can lead to:
- Inconsistent permission models
- Overly permissive configurations
- Hidden access paths not visible at higher directory levels

Misuse of inheritance controls is a frequent cause of security gaps.

---

## Real-World Abuse Scenarios

---

### Taking Ownership of Sensitive Files

- An attacker with sufficient privileges takes ownership of:
  - System binaries
  - Service executables
- Modifies permissions to allow write access
- Replaces binaries to execute malicious code

---

### Modifying Inherited Permissions

- Inheritance is disabled on a target directory
- Attacker sets permissive explicit permissions
- Gains persistent access without affecting parent policies

This technique is often used to evade detection.

---

## Defensive Perspective

---

### Monitoring Ownership Changes

- Ownership changes are high-risk events
- Should be audited and logged
- Unexpected ownership modifications may indicate compromise

---

### Detecting Abnormal Permission Changes

- Monitor for:
  - Sudden permission escalations
  - Removal of restrictive ACEs
  - Addition of broad access entries (e.g., Everyone)

- Correlate with process activity and user context

Effective detection relies on visibility into both ownership and ACL modifications.

---

## Key Takeaways

- File ownership determines ultimate control over an object
- Owners can modify permissions regardless of existing ACLs
- Permission inheritance simplifies management but introduces risks
- Breaking inheritance can create hidden security weaknesses
- Ownership and inheritance are common targets in privilege escalation
- Monitoring changes to ownership and permissions is critical for defense