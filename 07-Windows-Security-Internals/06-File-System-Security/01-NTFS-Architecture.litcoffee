# 01-NTFS-Architecture

## Overview

NTFS (New Technology File System) is the primary file system used by modern Windows operating systems. It is designed to provide high performance, reliability, and advanced security features. Understanding NTFS architecture is essential for security professionals, as it directly impacts access control, data integrity, and forensic visibility.

---

## What NTFS Is

NTFS is a journaling file system developed by Microsoft to replace older file systems such as FAT and FAT32. It supports large volumes, advanced metadata structures, and fine-grained security controls.

Key characteristics:
- Metadata-driven architecture
- Support for large files and volumes
- Integrated security model
- Built-in fault tolerance mechanisms

---

## Why It Is Used in Windows

NTFS is the default file system in Windows due to its:

- Strong access control capabilities
- Support for auditing and logging
- Reliability through journaling
- Compatibility with enterprise security features
- Ability to enforce permissions at file and directory levels

---

## NTFS Core Components

NTFS is structured around metadata and system files that manage all aspects of file storage and access.

---

### Master File Table (MFT)

The Master File Table is the central component of NTFS.

- Every file and directory is represented as a record in the MFT
- Acts as a database of all filesystem objects
- Stores metadata rather than raw file data (in most cases)

Each file has at least one MFT entry.

---

### File Records

- Fixed-size records (typically 1 KB)
- Contain attributes describing the file
- May include:
  - File name
  - Security descriptor
  - Data location

Small files may be stored directly inside the MFT record (resident data).

---

### Metadata Files

NTFS uses special system files (hidden) to manage internal operations.

Examples include:
- $MFT (Master File Table)
- $LogFile (transaction log)
- $Bitmap (allocation tracking)
- $Secure (security descriptors)

These files are critical for filesystem integrity and security enforcement.

---

## File Structure and Attributes

NTFS uses an attribute-based model rather than a simple block-based structure.

---

### Data Streams

- Files can contain multiple data streams
- The default stream stores main file data
- Alternate Data Streams (ADS) allow hidden data storage

Example concept:
  
  filename.txt:secret_data

ADS is often abused for stealthy data storage.

---

### File Attributes

Each file is composed of attributes, such as:

- $STANDARD_INFORMATION (timestamps, flags)
- $FILE_NAME
- $DATA (actual content)
- $SECURITY_DESCRIPTOR

Attributes define both data and metadata.

---

### Directory Structure

- Directories are implemented as indexed files
- Use B-tree structures for efficient lookup
- Store references to file records in the MFT

This enables fast file searching and scalability.

---

## Journaling and Reliability

NTFS includes mechanisms to ensure consistency in case of system failure.

---

### NTFS Logging Mechanism

- Uses a transaction-based logging system
- Changes are recorded in $LogFile before being committed
- Ensures recoverability of operations

---

### Crash Recovery

- On system crash, NTFS replays the log
- Restores filesystem to a consistent state
- Prevents corruption and data loss

---

## Security Features in NTFS

NTFS integrates security directly into the filesystem.

---

### Built-in Access Control

- Each file and directory has a security descriptor
- Includes:
  - Owner SID
  - Discretionary Access Control List (DACL)
  - System Access Control List (SACL)

Access decisions are enforced by the Windows Security Reference Monitor.

---

### Encryption (EFS) Overview

- Encrypting File System (EFS) provides file-level encryption
- Uses user-specific encryption keys
- Transparent to authorized users

Data remains encrypted on disk.

---

### Auditing Capabilities

- NTFS supports auditing via SACLs
- Tracks access attempts (success/failure)
- Integrated with Windows Event Logging

Used heavily in security monitoring and incident response.

---

## Security Implications

---

### Why NTFS is Critical for Access Control

- Enforces fine-grained permissions at file and directory level
- Supports least privilege principles
- Integrates with Windows authentication and authorization

Misconfigured NTFS permissions are a common source of privilege escalation.

---

### Role in Forensic Investigations

NTFS provides valuable forensic artifacts:

- MFT records (file existence, timestamps)
- $LogFile (recent changes)
- $UsnJrnl (file activity tracking)
- Alternate Data Streams (hidden data)

These artifacts help reconstruct attacker activity and timelines.

---

## Key Takeaways

- NTFS is a metadata-driven, secure, and reliable file system
- The Master File Table is the core structure representing all files
- Security is enforced through integrated access control mechanisms
- Journaling ensures data integrity and recoverability
- NTFS artifacts are critical for detection, investigation, and response