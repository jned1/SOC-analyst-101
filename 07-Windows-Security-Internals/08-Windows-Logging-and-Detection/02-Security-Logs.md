# 02-Security-Logs

## Overview

The Windows Security log is a critical component of the Event Logging system, dedicated to recording security-relevant events. It provides detailed visibility into authentication, authorization, and access control activities across the system.

For security operations, the Security log is one of the most valuable data sources for detecting attacks, investigating incidents, and monitoring user behavior.

---

## Purpose of the Security Log

The Security log is designed to capture events related to:

- User authentication (logon and logoff)
- Account changes and management
- Access to secured objects
- Privilege usage
- Policy modifications

These events are generated based on configured audit policies.

---

## Role in Monitoring Authentication and Access

The Security log enables:

- Tracking who accessed the system and when
- Monitoring access to sensitive resources
- Identifying unauthorized or suspicious activity
- Enforcing accountability through audit trails

It is essential for both real-time detection and post-incident analysis.

---

## Key Event Categories

---

### Logon Events

- Record authentication attempts
- Include both successful and failed logons
- Provide details such as:
  - User account
  - Logon type
  - Source IP or workstation

---

### Account Management

- Track changes to user and group accounts
- Examples:
  - Account creation or deletion
  - Password changes
  - Group membership modifications

---

### Object Access

- Record access attempts to secured resources
- Includes:
  - Files
  - Registry keys
  - Other protected objects

Requires object auditing to be enabled.

---

### Policy Changes

- Track modifications to security policies
- Includes:
  - Audit policy changes
  - User rights assignments

These changes can significantly impact system security.

---

### Privilege Use

- Record usage of sensitive privileges
- Examples:
  - Debug privileges
  - Backup and restore privileges

Often associated with high-risk activities.

---

## Important Event IDs

---

### Successful Logon

- Event ID: 4624
- Indicates a successful authentication

Key details:
- Logon type
- User account
- Source information

---

### Failed Logon

- Event ID: 4625
- Indicates a failed authentication attempt

Important for detecting:
- Brute force attacks
- Unauthorized access attempts

---

### Account Changes

- Event IDs:
  - 4720 (account created)
  - 4722 (account enabled)
  - 4726 (account deleted)
  - 4732 (added to group)

Used to monitor identity changes and potential misuse.

---

### Privilege Escalation Indicators

- Event IDs:
  - 4672 (special privileges assigned)
  - 4688 (process creation with elevated context)

These events may indicate:
- Administrative logons
- Privileged process execution

---

## Logon Types

---

### Interactive

- Logon Type: 2
- User logs in directly via console or local session

---

### Network

- Logon Type: 3
- Access to shared resources over the network

---

### Remote (RDP)

- Logon Type: 10
- Remote interactive logon via Remote Desktop Protocol

---

### Service

- Logon Type: 5
- Used by services to start under specific accounts

---

## Security Use Cases

---

### Detecting Brute Force Attacks

- Multiple failed logon events (4625)
- Followed by a successful logon (4624)

Indicators:
- Repeated attempts from same source
- Rapid succession of failures

---

### Identifying Lateral Movement

- Network logons (Type 3) across multiple systems
- Use of administrative accounts

Indicators:
- Unusual access patterns
- Logons from unexpected hosts

---

### Monitoring Privilege Escalation

- Events indicating privilege assignment (4672)
- Elevated process creation (4688)

Indicators:
- Non-admin users gaining elevated rights
- Execution of administrative tools

---

## SOC Perspective

---

### Correlation of Multiple Events

Single events are often insufficient. Effective detection requires:

- Linking logon events with process creation
- Correlating account changes with privilege usage
- Identifying sequences of suspicious behavior

---

### Building Detection Logic

Detection strategies should include:

- Threshold-based alerts (e.g., multiple failed logons)
- Behavioral patterns (e.g., unusual logon times)
- Context-aware analysis (user role, system sensitivity)

Combining multiple signals improves accuracy and reduces false positives.

---

## Key Takeaways

- The Security log is the primary source for authentication and access monitoring
- It records logon events, account changes, and privilege usage
- Event IDs provide structured identification of activities
- Logon types help determine how access was obtained
- Effective detection relies on correlating multiple events
- Security logs are essential for identifying attacks and supporting investigations