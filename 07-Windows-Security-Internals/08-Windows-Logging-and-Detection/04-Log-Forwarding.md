# 04-Log-Forwarding

## Overview

Log forwarding is the process of collecting event logs from multiple systems and centralizing them into a single location for analysis. In Windows environments, this is commonly implemented using Windows Event Forwarding (WEF).

Centralized logging is a foundational capability for detection, monitoring, and incident response, especially in enterprise-scale environments.

---

## Why Centralized Logging is Important

Centralized logging enables:

- Unified visibility across multiple endpoints
- Efficient monitoring and alerting
- Faster incident detection and response
- Long-term log retention for investigations

Without centralized logging, security teams are limited to isolated system analysis.

---

## Challenges of Local Logs

Relying on local logs introduces several risks:

- Logs can be deleted or tampered with by attackers
- Limited storage leads to log overwriting
- Difficult to correlate events across systems
- Manual access is inefficient and time-consuming

These limitations reduce detection capability and forensic reliability.

---

## Windows Event Forwarding (WEF)

Windows Event Forwarding is a native Windows feature used to collect and forward event logs from multiple systems to a central collector.

It leverages the Windows Remote Management (WinRM) protocol for communication.

---

### Source-Initiated vs Collector-Initiated

Source-Initiated:

- Endpoints (sources) push logs to the collector
- Scales well for large environments
- Easier to manage in distributed networks

Collector-Initiated:

- Collector pulls logs from specific endpoints
- Requires explicit configuration of each source
- Suitable for smaller or controlled environments

---

## Components Involved

WEF consists of:

- Event sources (endpoints generating logs)
- Event collectors (central systems receiving logs)
- Subscriptions (rules defining which events to collect)

---

## Architecture

---

### Event Collectors

- Central systems configured to receive forwarded events
- Store logs in the "Forwarded Events" channel
- Can be standalone or integrated with SIEM solutions

---

### Subscriptions

- Define what events are collected
- Include:
  - Log sources (e.g., Security, System)
  - Event IDs or filters
  - Delivery mode (push or pull)

Subscriptions control data flow and filtering.

---

### Communication Flow

1. Event is generated on the source system
2. Event matches subscription criteria
3. Event is forwarded via WinRM
4. Collector receives and stores the event
5. Events are available for analysis and monitoring

---

## Benefits

---

### Centralized Monitoring

- Consolidates logs from multiple systems
- Enables unified visibility and alerting

---

### Reduced Risk of Log Tampering

- Logs are stored remotely from the source system
- Attackers have limited ability to erase evidence

---

### Scalability

- Supports large numbers of endpoints
- Efficient filtering reduces unnecessary data transfer

---

## Security Implications

---

### Importance in Enterprise Environments

- Essential for monitoring large, distributed infrastructures
- Enables detection of coordinated attacks across systems
- Supports compliance and audit requirements

---

### Supporting SIEM Integration

- Forwarded logs can be ingested into SIEM platforms
- Enables:
  - Advanced correlation
  - Threat detection
  - Automated response

WEF acts as a data pipeline into centralized analysis systems.

---

## SOC Perspective

---

### Log Aggregation

- Collect logs from endpoints, servers, and critical systems
- Normalize and store for analysis

Aggregation is the foundation for detection engineering.

---

### Correlation Across Endpoints

- Identify patterns across multiple systems
- Detect:
  - Lateral movement
  - Distributed attacks
  - Coordinated activity

Correlation significantly improves detection accuracy.

---

## Key Takeaways

- Log forwarding centralizes event data for analysis and monitoring
- Windows Event Forwarding (WEF) is the native solution for log collection
- Source-initiated mode scales better for large environments
- Centralized logs reduce the risk of tampering and data loss
- Integration with SIEM enables advanced detection and correlation
- Effective SOC operations rely on aggregated and correlated log data