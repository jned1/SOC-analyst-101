# 01-Registry-Architecture

## Overview

The Windows Registry is a centralized, hierarchical database that stores configuration settings for the operating system, hardware, users, and applications. It is a critical component of Windows internals and plays a central role in system behavior, persistence mechanisms, and security enforcement.

Understanding the architecture of the Registry is essential for security analysis, incident response, and detecting malicious activity.

---

## What the Windows Registry Is

The Windows Registry is a structured data store used to maintain configuration information required for system operation.

It contains:
- Operating system settings
- User-specific configurations
- Application parameters
- Hardware and driver information

Unlike flat configuration files, the Registry provides a unified and efficient mechanism for managing system state.

---

## Why It Exists and Its Role in the OS

The Registry was introduced to replace fragmented configuration storage (e.g., INI files).

Its primary roles include:
- Centralizing configuration management
- Enabling fast read/write access to system settings
- Supporting multi-user environments
- Providing a consistent interface for applications and services

The Registry is accessed continuously by both the operating system and applications.

---

## Registry Structure

The Registry is organized in a hierarchical format similar to a filesystem.

---

### Keys and Subkeys

- Keys are analogous to directories
- Subkeys are nested keys within a parent key

Examples of root-level keys (hives):
- HKEY_LOCAL_MACHINE (HKLM)
- HKEY_CURRENT_USER (HKCU)
- HKEY_CLASSES_ROOT (HKCR)
- HKEY_USERS (HKU)
- HKEY_CURRENT_CONFIG (HKCC)

Each key can contain subkeys and values.

---

### Values and Data Types

Values are the actual data entries stored within keys.

Each value consists of:
- Name
- Data
- Data type

Common data types:
- REG_SZ (string)
- REG_DWORD (32-bit integer)
- REG_QWORD (64-bit integer)
- REG_BINARY (raw binary data)
- REG_MULTI_SZ (multi-string)

These types define how data is interpreted by the system.

---

### Logical Hierarchy

The Registry follows a tree-like structure:

- Root keys (top level)
- Subkeys (branches)
- Values (leaf data)

This hierarchy allows efficient organization and retrieval of configuration data.

---

## Logical vs Physical Structure

---

### Registry as a Database-Like System

Logically, the Registry behaves like a database:
- Indexed structure for fast lookup
- Hierarchical organization
- Centralized access control

Applications query and modify it using structured APIs rather than direct file access.

---

### Mapping to Files on Disk

Physically, the Registry is stored in files known as hives.

Common hive file locations:
- System-wide hives:
  - %SystemRoot%\System32\Config\
- User-specific hives:
  - NTUSER.DAT (per user profile)

Each hive corresponds to a logical root key or subkey.

The in-memory representation may differ from on-disk storage due to caching and transaction handling.

---

## Registry Access Mechanisms

---

### APIs Used to Read/Write Registry

Applications interact with the Registry through Windows APIs, such as:

- RegOpenKeyEx
- RegQueryValueEx
- RegSetValueEx
- RegCreateKeyEx

These APIs provide controlled access and enforce security boundaries.

---

### User-Mode vs Kernel-Mode Interaction

- User-mode:
  - Applications and user processes access the Registry via standard APIs
  - Subject to access control enforcement

- Kernel-mode:
  - The Configuration Manager handles low-level Registry operations
  - Ensures consistency, caching, and synchronization

This separation ensures stability and security of Registry operations.

---

## Security Role of the Registry

---

### Configuration Storage

The Registry stores critical system and security configurations, including:
- Startup programs
- Service configurations
- Driver settings
- Security policies

Compromise of these entries can directly impact system behavior.

---

### System and Application Behavior Control

The Registry controls:
- Application execution behavior
- User environment settings
- Security mechanisms (e.g., UAC, policies)

Attackers often manipulate these settings to achieve persistence or disable defenses.

---

## Security Implications

---

### Why Registry is a High-Value Target

The Registry is frequently targeted because:
- It controls system startup and persistence
- It stores sensitive configuration data
- It influences security mechanisms and policies

Unauthorized modifications can result in:
- Persistent malware execution
- Privilege escalation
- Defense evasion

---

### Importance in Forensic Investigations

The Registry provides valuable forensic artifacts, such as:
- Recently executed programs
- User activity traces
- System configuration history
- Persistence mechanisms

Analysis of Registry hives is critical for reconstructing attacker behavior.

---

## Key Takeaways

- The Windows Registry is a hierarchical, database-like configuration system
- It centralizes system, user, and application settings
- Keys, subkeys, and values form its logical structure
- Registry data is stored in hive files on disk
- It is accessed via controlled APIs in both user and kernel modes
- The Registry is a high-value target for attackers and a key source of forensic evidence