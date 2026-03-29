# 03-Sysmon-and-ETW

## Overview

Windows provides native logging through the Event Log system, but it is often insufficient for detailed security monitoring. Advanced threats frequently operate in ways that generate limited or no visibility in default logs.

Enhanced logging mechanisms such as Sysmon and Event Tracing for Windows (ETW) provide deeper insight into system activity, enabling detection of sophisticated attacker techniques.

---

## Why Native Logs Are Not Enough

Default Windows logs have limitations:

- Limited visibility into process behavior
- Insufficient detail on command-line execution
- Minimal tracking of file and network activity
- Lack of context for advanced threat detection

Attackers often exploit these gaps to remain undetected.

---

## Introduction to Enhanced Logging

Enhanced logging solutions extend visibility by:

- Capturing detailed system activity
- Providing context-rich event data
- Enabling fine-grained monitoring
- Supporting advanced detection use cases

Sysmon and ETW are two key technologies used to achieve this.

---

## Sysmon Overview

---

### What Sysmon Is

Sysmon (System Monitor) is a Windows system service and driver that logs detailed system activity to the Event Log.

It is part of the Sysinternals suite and is widely used in security monitoring.

---

### Role in Endpoint Monitoring

Sysmon enhances endpoint visibility by recording:

- Process execution details
- Network connections
- File system activity
- Driver and module loading

It enables defenders to track attacker behavior at a granular level.

---

### Configuration-Based Logging

- Sysmon is controlled via a configuration file
- Administrators define:
  - Which events to capture
  - Filtering rules
  - Logging conditions

This allows tailored monitoring based on security requirements.

---

## Key Sysmon Events

---

### Process Creation

- Event ID: 1
- Captures:
  - Executable path
  - Command-line arguments
  - Parent process

Critical for detecting malicious execution.

---

### Network Connections

- Event ID: 3
- Logs outbound network activity
- Includes:
  - Destination IP and port
  - Process initiating connection

Useful for detecting command-and-control communication.

---

### Image Loading

- Event ID: 7
- Tracks DLL and module loading
- Helps identify:
  - DLL hijacking
  - Suspicious module injection

---

### File Creation

- Event ID: 11
- Records file creation events
- Useful for detecting:
  - Dropped malware
  - Unauthorized file changes

---

## ETW (Event Tracing for Windows)

---

### What ETW Is

ETW is a high-performance event tracing framework built into Windows.

It allows real-time collection of detailed system and application events.

---

### Real-Time Event Tracing

- Events are generated and consumed in real time
- Supports high-frequency, low-overhead logging
- Used by both Microsoft components and security tools

---

### Providers and Consumers

- Providers:
  - Components that generate events
  - Examples:
    - Kernel
    - Drivers
    - Applications

- Consumers:
  - Tools or services that receive and process events

ETW enables flexible and scalable event collection.

---

## Sysmon vs ETW

---

### Differences and Use Cases

Sysmon:
- Installed as a separate tool
- Writes events to Windows Event Logs
- Configuration-driven
- Easier to deploy and integrate

ETW:
- Built into the operating system
- Provides real-time event streams
- Requires specialized tools to consume
- Offers deeper and more granular visibility

---

### When to Use Each

- Use Sysmon:
  - For structured, persistent logging
  - For SIEM integration
  - For endpoint detection use cases

- Use ETW:
  - For real-time monitoring
  - For advanced threat hunting
  - For deep system analysis

Both are often used together for comprehensive visibility.

---

## Security Implications

---

### Visibility into Attacker Behavior

Enhanced logging enables detection of:

- Process injection
- Command execution
- Lateral movement
- Data exfiltration

It provides the context needed to understand attacker actions.

---

### Detecting Stealthy Techniques

- Fileless malware
- Living-off-the-land techniques
- Obfuscated command execution

These techniques often evade traditional logging but can be detected with Sysmon and ETW.

---

## SOC Perspective

---

### Using Sysmon for Detection Rules

- Build detection logic based on:
  - Process creation patterns
  - Command-line anomalies
  - Network connections

- Integrate with SIEM for alerting and correlation

---

### Leveraging ETW for Deep Visibility

- Use ETW for:
  - Real-time threat hunting
  - Detailed behavioral analysis
  - Investigating advanced attacks

- Combine with other telemetry sources for full visibility

---

## Key Takeaways

- Native Windows logs provide limited visibility for modern threats
- Sysmon enhances endpoint logging with detailed, configurable events
- ETW provides real-time, high-performance event tracing
- Sysmon is easier to deploy, while ETW offers deeper insight
- Both technologies are critical for detecting advanced attacker techniques
- Effective security monitoring relies on enhanced logging and correlation