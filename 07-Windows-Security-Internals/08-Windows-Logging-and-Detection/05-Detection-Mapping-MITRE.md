# 05-Detection-Mapping-MITRE

## Overview

Detection mapping is the process of aligning observed system activity and log data with known adversary behaviors. It enables security teams to understand what an attacker is doing in terms of tactics and techniques, rather than isolated events.

Using structured frameworks improves detection consistency, coverage, and the ability to respond effectively to threats.

---

## What Detection Mapping Is

Detection mapping involves:

- Correlating logs and telemetry with attacker behaviors
- Translating raw events into meaningful security insights
- Identifying which phase of an attack lifecycle is occurring

It shifts focus from individual alerts to behavioral understanding.

---

## Why Frameworks Are Important

Frameworks provide:

- Standardized terminology
- Structured representation of attacker behavior
- Guidance for building detection strategies
- Improved communication between security teams

They allow defenders to systematically identify gaps in visibility and detection.

---

## MITRE ATT&CK Framework

---

### Purpose of MITRE ATT&CK

MITRE ATT&CK is a knowledge base of adversary tactics and techniques based on real-world observations.

It is used to:

- Model attacker behavior
- Map detections to known techniques
- Guide threat hunting and incident response
- Assess detection coverage

---

### Tactics vs Techniques

- Tactics:
  - High-level objectives of an attacker
  - Examples:
    - Initial Access
    - Execution
    - Persistence
    - Privilege Escalation

- Techniques:
  - Specific methods used to achieve a tactic
  - Example:
    - Command execution via PowerShell

Tactics represent the "why," while techniques represent the "how."

---

## Mapping Logs to Techniques

Different log sources provide visibility into different attack techniques.

---

### Authentication Logs → Credential Access

- Source: Security logs (logon events)
- Detection focus:
  - Brute force attempts
  - Credential misuse
  - Unauthorized access patterns

Mapped tactics:
- Credential Access
- Initial Access

---

### Process Logs → Execution

- Source: Sysmon, Event ID 4688
- Detection focus:
  - Command-line execution
  - Suspicious parent-child relationships
  - Use of scripting engines

Mapped tactics:
- Execution
- Defense Evasion

---

### Registry Logs → Persistence

- Source: Registry auditing, Sysmon
- Detection focus:
  - Changes to autorun keys
  - Modification of service configurations
  - Winlogon manipulation

Mapped tactics:
- Persistence
- Privilege Escalation

---

## Detection Examples

---

### Mapping Logon Events to Lateral Movement

Indicators:
- Multiple logon events across systems
- Use of administrative accounts
- Network logon types (Type 3)

Mapped technique:
- Lateral Movement via remote services or credential reuse

---

### Mapping Process Creation to Execution Techniques

Indicators:
- Execution of command interpreters (cmd, PowerShell)
- Encoded or obfuscated command lines
- Unusual parent processes

Mapped techniques:
- Command and scripting interpreter abuse
- Living-off-the-land techniques

---

## Building Detection Logic

---

### Combining Multiple Data Sources

Effective detection requires correlation across:

- Security logs (authentication)
- Sysmon (process and network activity)
- Registry logs (persistence)

Combining these sources provides a complete view of attacker behavior.

---

### Behavioral Detection vs Signature Detection

- Signature-based detection:
  - Matches known patterns
  - Limited against new or obfuscated threats

- Behavioral detection:
  - Focuses on actions and patterns
  - More resilient to evasion

Modern detection strategies prioritize behavior over static signatures.

---

## SOC Perspective

---

### Using MITRE for Investigations

- Map observed activity to ATT&CK techniques
- Understand attacker objectives and progression
- Identify missing telemetry or detection gaps

This improves investigation accuracy and speed.

---

### Improving Detection Coverage

- Evaluate which techniques are detectable
- Identify blind spots in logging or monitoring
- Expand detection rules to cover more tactics

Continuous mapping strengthens overall security posture.

---

## Key Takeaways

- Detection mapping connects raw logs to attacker behavior
- MITRE ATT&CK provides a structured framework for this process
- Tactics describe goals, while techniques describe methods
- Different log sources map to different attack stages
- Effective detection relies on correlating multiple data sources
- Behavioral detection is more effective than signature-based approaches
- Mapping improves visibility, detection coverage, and incident response