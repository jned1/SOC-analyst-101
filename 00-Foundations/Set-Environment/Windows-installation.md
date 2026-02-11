# Windows VM Installation – SOC Lab

## 1. Purpose of the Windows VM

Windows systems dominate enterprise environments. Most organizations rely on Windows for employee workstations, Active Directory infrastructure, authentication services, and business applications. Because of this dominance, Windows endpoints generate the majority of security-relevant events in a corporate SOC.

From a SOC perspective, Windows is important because:

- Most user activity happens on Windows endpoints.
- Authentication, privilege escalation, and lateral movement often involve Windows systems.
- Malware is frequently designed to target Windows environments.

Attackers focus on Windows because it is widely deployed and deeply integrated with enterprise identity systems. If an attacker compromises a Windows endpoint, they often gain a foothold into the organization’s network. Therefore, understanding Windows logs, processes, and behaviors is essential for detection and incident response.

This VM represents a typical employee workstation in a corporate environment. It acts as both a log source and a potential attack surface.

---

## 2. ISO Selection

I selected a modern enterprise-relevant version of Windows (such as Windows 10 Enterprise or Windows 11 Enterprise).

The reason for choosing an enterprise edition instead of a home edition is that enterprise environments commonly use:

- Active Directory integration
- Group Policy management
- Advanced logging and auditing capabilities
- Enterprise security features

Using a realistic version ensures that the logs, services, and configurations I observe in the lab reflect real-world SOC scenarios. A SOC analyst must become familiar with enterprise logging behavior, not consumer-grade system defaults.

Selecting a widely deployed version also helps simulate real attacker techniques that are commonly observed in production environments.

---

## 3. VM Configuration

### CPU, RAM, and Disk Allocation

The Windows VM was configured with:

- 2 CPU cores  
- 4–8 GB RAM  
- 50–80 GB disk space  

From a SOC perspective, resource allocation affects system behavior and logging reliability.

Adequate RAM ensures:
- The system runs smoothly under simulated load.
- Logs are generated consistently.
- Security tools do not crash due to resource starvation.

Sufficient disk space is critical because:
- Windows Event Logs grow over time.
- Updates and security patches require storage.
- Log overflow can cause loss of valuable forensic data.

Under-provisioned systems may produce artificial performance issues that do not reflect realistic enterprise conditions.

### Network Configuration

The VM was connected to an Internal or Host-Only network for lab communication. NAT was optionally enabled for updates.

This network design ensures:

- The Windows VM can communicate with the SIEM.
- It can interact with the attacker machine for simulation.
- It remains isolated from the physical network.

Isolation is essential because:

- Simulated attacks must not escape the lab.
- Potential malware testing must remain contained.
- Network scans should not affect real devices.

From a SOC viewpoint, segmentation mirrors enterprise defensive design.

---

## 4. Installation Process Overview

The installation followed standard Windows setup steps:

1. Boot from ISO.
2. Select language and region.
3. Choose installation type.
4. Allocate disk space.
5. Complete user account setup.

During initial setup, I made decisions aligned with enterprise simulation:

- Created a local user account representing an employee.
- Used a strong password to simulate realistic policy enforcement.
- Disabled unnecessary consumer features to reduce noise.

These decisions matter because SOC analysts must distinguish between normal background noise and meaningful security events. A clean baseline improves detection clarity.

---

## 5. Post-Installation Configuration

### System Updates

After installation, I performed system updates.

Why this matters:

- Enterprises regularly patch systems.
- Vulnerabilities are often exploited when systems are unpatched.
- Updated systems produce realistic logging behavior for modern security features.

Understanding patch levels is critical in incident investigations.

---

### Hostname Configuration

I assigned a meaningful hostname (e.g., WIN-CLIENT01).

This reflects enterprise naming conventions and helps:

- Identify systems quickly in SIEM dashboards.
- Correlate logs accurately.
- Simulate multi-endpoint environments.

Clear naming improves investigation efficiency.

---

### Network Verification

I verified:

- IP address assignment
- Network connectivity to other lab machines
- Basic communication with the SIEM

From a SOC perspective, log forwarding depends on reliable network connectivity. Misconfigured networking results in blind spots, and blind spots are dangerous in security monitoring.

---

### Enabling Logging Features

I reviewed and configured:

- Windows Event Logging settings
- Audit policies (logon events, object access, process creation)
- Advanced auditing options

Default logging is often insufficient for security investigations. Enabling additional audit categories improves visibility into:

- Authentication attempts
- Privilege changes
- Process execution
- File access

More visibility means better detection capability.

---

### Installing Sysmon (Conceptual Overview)

Sysmon (System Monitor) is a Windows system service that enhances logging by capturing detailed system activity.

It can log:

- Process creation with command-line arguments
- Network connections
- File creation timestamps
- Driver loading events

From a SOC perspective, Sysmon fills gaps in default Windows logging. It provides deeper telemetry that supports advanced detection techniques such as identifying suspicious parent-child process relationships.

This transforms the endpoint from a basic system into a rich forensic data source.

---

## 6. Logging Importance

### Windows Event Logs Explained

Windows Event Logs are structured records of system activity stored in categorized channels such as:

- Application
- System
- Security

Each event includes:

- Timestamp
- Event ID
- Source
- Detailed message

These structured logs allow correlation and rule-based detection.

---

### Security Log Relevance

The Security log is one of the most critical sources for SOC monitoring. It records:

- Successful and failed logon attempts
- Account lockouts
- Privilege assignments
- Audit policy changes

Authentication events are central to detecting:

- Brute force attempts
- Credential abuse
- Lateral movement

Without proper auditing, these behaviors would remain invisible.

---

### Why Endpoints Are Critical Log Sources

Endpoints represent the entry point for most attacks. Even when the target is a server, attackers often begin with a compromised workstation.

Endpoints generate:

- Process creation events
- File execution logs
- Network connection data
- Authentication attempts

A SOC that ignores endpoint telemetry operates with limited visibility. Proper endpoint configuration ensures high-quality, actionable logs.

---

## 7. Learning Reflection

Setting up the Windows VM deepened my understanding of:

- How Windows manages processes and services.
- How authentication events are recorded.
- How logging policies directly affect detection capability.
- How system configuration impacts visibility.

I realized that detection quality depends heavily on proper configuration. A poorly configured endpoint generates incomplete logs, which weakens investigations.

SOC analysts rely on data integrity. If logging is incomplete or misconfigured, even advanced detection tools cannot compensate.

---

## Summary

This Windows VM serves as a realistic enterprise endpoint within my SOC lab. By configuring it with proper resources, network isolation, and enhanced logging, I transformed it from a simple operating system into a valuable telemetry source.  

It now generates the type of security-relevant data that real SOC analysts monitor daily, forming the foundation for detection, alerting, and investigation workflows in my lab environment.
