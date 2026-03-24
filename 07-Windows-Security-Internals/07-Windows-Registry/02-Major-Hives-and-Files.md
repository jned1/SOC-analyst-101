# 02-Major-Hives-and-Files

## Overview

The Windows Registry is divided into logical sections known as hives. Each hive represents a distinct portion of the system or user configuration. This separation improves manageability, performance, and security by isolating different types of data.

Understanding registry hives and their corresponding files is critical for security analysis, privilege escalation detection, and forensic investigations.

---

## What Registry Hives Are

A registry hive is a logical container that stores a subset of the Registry’s configuration data.

Each hive:
- Represents a root-level structure in the Registry
- Contains keys, subkeys, and values
- Maps to one or more physical files on disk

Hives are loaded into memory during system operation.

---

## Purpose of Hive Separation

The Registry is divided into multiple hives to:

- Isolate system-wide and user-specific configurations
- Improve performance through modular loading
- Enhance security by limiting access scope
- Support multi-user environments

This separation allows controlled access to different parts of the system configuration.

---

## Major Registry Hives

---

### HKEY_LOCAL_MACHINE (HKLM)

- Contains system-wide configuration settings
- Applies to all users on the system

Key areas include:
- Hardware configuration
- Installed software
- System services and drivers
- Security policies

This hive is critical for system operation and a common target for persistence and privilege escalation.

---

### HKEY_CURRENT_USER (HKCU)

- Contains configuration specific to the currently logged-in user
- Derived from the user’s profile (NTUSER.DAT)

Stores:
- User preferences
- Environment settings
- Application configurations

Frequently abused for user-level persistence mechanisms.

---

### HKEY_CLASSES_ROOT (HKCR)

- Manages file associations and COM object registrations
- Merges data from:
  - HKLM\Software\Classes
  - HKCU\Software\Classes

Controls:
- File type handling
- Application execution via file extensions

Abuse can lead to execution hijacking.

---

### HKEY_USERS (HKU)

- Contains profiles for all users loaded on the system
- Each user is identified by their SID

Includes:
- Individual user configurations
- Default user profile settings

HKCU is a pointer to a specific subkey within HKU.

---

### HKEY_CURRENT_CONFIG (HKCC)

- Stores current hardware configuration profile
- Derived from HKLM\SYSTEM

Includes:
- Display settings
- Device configurations

Typically less targeted but relevant in hardware-based configurations.

---

## Important Subkeys for Security

---

### SAM

- Located under HKLM\SAM
- Contains local user account information
- Stores password hashes (protected)

Highly sensitive and restricted access.

---

### SECURITY

- Located under HKLM\SECURITY
- Stores security policy data
- Includes LSA secrets

Used for authentication and policy enforcement.

---

### SOFTWARE

- Located under HKLM\SOFTWARE
- Stores installed application configurations
- Includes startup entries and application settings

Common target for persistence techniques.

---

### SYSTEM

- Located under HKLM\SYSTEM
- Contains system configuration data
- Includes:
  - Services
  - Drivers
  - Control sets

Critical for system boot and service execution.

---

## Registry Files on Disk

---

### Location of Hive Files

System-wide registry hives are stored in:

  %SystemRoot%\System32\Config\

User-specific hives are stored in:

  C:\Users\<Username>\

---

### SYSTEM, SAM, SECURITY, SOFTWARE Files

Located in:

  %SystemRoot%\System32\Config\

Key files:
- SYSTEM → System configuration and services
- SAM → User account database
- SECURITY → Security policies and secrets
- SOFTWARE → Installed applications and settings

These files are locked while the system is running.

---

### NTUSER.DAT

- Located in each user’s profile directory
- Represents HKCU for that user

Contains:
- User preferences
- Application settings
- User-specific persistence entries

---

## Volatile vs Persistent Data

---

### Runtime vs Stored Configuration

- Persistent data:
  - Stored in hive files on disk
  - Survives system reboots

- Volatile data:
  - Exists only in memory
  - Created during runtime
  - Lost after reboot

Example:
- Hardware configuration data may be dynamically generated

Understanding this distinction is important for forensic analysis.

---

## Security Implications

---

### Credential Storage Locations

Sensitive data stored in Registry hives includes:

- Password hashes (SAM)
- LSA secrets (SECURITY)
- Cached credentials

Attackers target these locations for credential extraction.

---

### System Configuration Manipulation

Attackers can modify registry keys to:

- Establish persistence (e.g., autorun keys)
- Alter service configurations
- Disable security mechanisms

Registry modifications are a common technique in post-exploitation.

---

## Key Takeaways

- Registry hives are logical containers that organize system and user configuration
- Each hive maps to physical files stored on disk
- Major hives separate system-wide and user-specific data
- Critical subkeys such as SAM and SECURITY store sensitive information
- NTUSER.DAT represents user-specific configuration
- The Registry is a high-value target for credential access and persistence mechanisms