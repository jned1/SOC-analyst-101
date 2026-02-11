# Ubuntu VM Installation – SOC Lab

## 1. Purpose of the Ubuntu VM

Linux servers are extremely common in enterprise environments. Many web servers, application servers, databases, cloud workloads, and security tools run on Linux distributions. Ubuntu, in particular, is widely adopted due to its stability, long-term support, and strong community ecosystem.

From a SOC perspective, Linux systems are critical because:

- Public-facing services often run on Linux.
- Web servers and APIs generate high-value security logs.
- Attackers frequently target Linux servers for persistence, data exfiltration, or lateral movement.

A SOC analyst who understands only Windows environments will miss key indicators from Linux infrastructure. Authentication logs, system logs, service logs, and network activity on Linux machines provide essential visibility into potential compromise.

In this lab, the Ubuntu VM simulates a backend server. It generates logs from services and authentication attempts, allowing me to monitor Linux-specific activity in addition to Windows endpoint behavior.

---

## 2. ISO Selection

I selected an Ubuntu Long-Term Support (LTS) version, such as Ubuntu Server 22.04 LTS.

LTS versions are preferred in production environments because:

- They receive extended security updates.
- They are more stable than short-term releases.
- Enterprises prioritize reliability over cutting-edge features.

SOC environments monitor systems that are expected to run continuously with minimal disruption. Using an LTS version ensures my lab reflects real enterprise deployment patterns rather than experimental configurations.

Stability matters because predictable system behavior makes anomaly detection more meaningful.

---

## 3. VM Configuration

### Resource Allocation

The Ubuntu VM was configured with:

- 1–2 CPU cores  
- 2–4 GB RAM  
- 20–40 GB disk space  

Linux servers generally require fewer graphical resources, especially when using a server edition without a desktop environment.

From a SOC perspective:

- Sufficient RAM ensures stable logging and service performance.
- Adequate disk space prevents log loss due to storage exhaustion.
- CPU allocation ensures realistic system responsiveness during simulated load.

Under-allocating resources can create artificial bottlenecks that distort monitoring results.

---

### Network Configuration

The VM was connected to the same Internal or Host-Only network as other lab machines.

This allows:

- Communication with the Windows endpoint.
- Log forwarding to the SIEM.
- Controlled interaction with the attacker machine.

Isolation is critical because:

- Simulated attacks must remain contained.
- Scans and brute-force attempts should not affect external systems.
- The lab should replicate segmented enterprise architecture.

This controlled networking mirrors real-world internal server zones.

---

## 4. Installation Overview

### Partitioning Choice

I selected the guided partitioning option using the entire virtual disk.

For lab purposes, simple partitioning is sufficient because:

- It reduces complexity.
- It allows focus on monitoring and logging rather than storage engineering.
- It reflects many small-to-medium enterprise deployments.

Understanding partitions is important, but overcomplicating storage in a SOC lab can distract from monitoring objectives.

---

### User Creation

During setup, I created a non-root user account with sudo privileges.

This reflects best practice:

- Direct root login is discouraged.
- Administrative actions are logged through privilege escalation.
- It simulates enterprise user management.

From a SOC perspective, privilege changes and sudo usage are valuable indicators during investigations.

---

### SSH Setup (Conceptual)

I enabled SSH service during installation.

SSH allows secure remote management of the server. In enterprise environments:

- Administrators manage servers remotely.
- SSH login attempts generate authentication logs.
- Failed login attempts can indicate brute-force attacks.

Enabling SSH allows me to simulate realistic remote access activity, which produces valuable log data.

---

## 5. Post-Installation Hardening

### System Updates

After installation, I updated all packages.

Why this matters:

- Production servers must be patched to reduce vulnerabilities.
- Outdated systems are frequent attack targets.
- Patch level awareness is important during incident response.

Understanding how updates affect services also improves operational awareness.

---

### Basic Firewall Configuration (Conceptual)

Ubuntu commonly uses a firewall tool such as UFW (Uncomplicated Firewall).

Basic firewall configuration allows:

- Restricting unnecessary inbound connections.
- Allowing only required services (e.g., SSH).
- Monitoring blocked connection attempts.

From a SOC perspective, firewall logs can reveal reconnaissance activity or unauthorized access attempts.

Proper firewall configuration reduces attack surface and improves signal clarity in logs.

---

### Log Verification (/var/log Overview)

Linux stores logs in the /var/log directory.

Key log files include:

- syslog or messages (general system activity)
- auth.log (authentication attempts)
- kern.log (kernel events)

Reviewing these logs helped me understand:

- How services record activity.
- Where login attempts are stored.
- How system events are structured.

Knowing log locations is foundational for centralized log collection.

---

## 6. Logging & SOC Relevance

### Syslog Explained

Syslog is a standard logging system used in Unix and Linux environments. It collects and stores system messages from:

- The kernel
- Services
- Applications

Syslog provides structured event records with timestamps and severity levels. This structure supports centralized aggregation into a SIEM.

Understanding syslog helps interpret:

- Service failures
- Configuration changes
- Suspicious background activity

---

### Authentication Logs

Authentication activity is recorded in files such as auth.log.

These logs capture:

- Successful SSH logins
- Failed login attempts
- Privilege escalation via sudo
- User account changes

From a SOC perspective, authentication logs are critical for detecting:

- Brute-force attacks
- Credential stuffing
- Unauthorized privilege escalation
- Suspicious remote access

Authentication monitoring is often the first line of detection in server compromise cases.

---

### Why Linux Log Analysis Matters

Many high-value enterprise services run on Linux servers. If a SOC ignores Linux logs, it creates a major visibility gap.

Linux log analysis allows detection of:

- Suspicious service behavior
- Unexpected user activity
- Malicious script execution
- Configuration tampering

Servers often hold sensitive data. Compromise at this level can lead to severe business impact. Proper logging ensures early detection.

---

## 7. Learning Reflection

Setting up Ubuntu felt different from Windows in several ways:

- Linux emphasizes command-line management.
- Logging is file-based and centralized under /var/log.
- Permissions and privilege escalation are more transparent.

Unlike Windows, where logs are accessed through Event Viewer, Linux logs are directly readable text files. This gives more direct insight into how events are recorded.

I also learned how important service-level logging is. Each application can generate its own logs, adding depth to investigations.

This VM supports centralized monitoring by acting as:

- A log source for server activity.
- A simulation of backend infrastructure.
- A target for controlled attack scenarios.

It broadens my monitoring skills beyond endpoint detection.

---

## Summary

The Ubuntu VM represents a realistic enterprise server within my SOC lab. By selecting an LTS version, configuring proper networking, enabling secure access, and understanding Linux logging structures, I built a stable and observable server environment.  

This system generates valuable telemetry that can be forwarded to a SIEM, helping me practice cross-platform monitoring and improving my ability to detect suspicious activity across both Windows and Linux infrastructures
