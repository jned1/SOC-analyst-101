# SOC Analyst Lab – Environment Setup

## 1. Lab Objective

I built this SOC (Security Operations Center) lab to move from theoretical cybersecurity knowledge to practical detection and monitoring skills. Reading about attacks is not enough. A SOC analyst must understand how systems behave under normal conditions and how they behave when something goes wrong. This lab gives me a controlled environment where I can observe both.

The main skills this lab is designed to develop include:

- Log analysis and interpretation  
- Understanding network traffic patterns  
- Endpoint monitoring and detection  
- Incident investigation workflow  
- Alert triage and correlation  

A real-world SOC monitors endpoints, servers, network devices, and applications. Analysts rely heavily on logs, alerts, and behavioral anomalies. My lab simulates this structure by creating multiple systems that generate activity, including normal user behavior and simulated attacks. Instead of reading alerts in isolation, I can see how they are generated, transported, and analyzed inside a monitoring platform.

This environment allows me to think like both a defender and an attacker, which is critical for building strong detection logic.

---

## 2. Virtualization Platform

I used a hypervisor (VirtualBox / VMware Workstation) to create and manage multiple virtual machines (VMs) on a single physical laptop.

Virtualization is necessary because:

- I need multiple operating systems running simultaneously.
- I must safely simulate attacks.
- I cannot risk infecting or misconfiguring my host operating system.

Using my main Windows system directly would expose it to malware, misconfigurations, and instability. A SOC lab requires freedom to experiment, break things, and rebuild systems. Virtual machines allow snapshots, which means I can revert to a clean state after testing.

Isolation is one of the most important principles in cybersecurity. In this lab:

- Each VM is separated from the host.
- Network communication is controlled.
- Risky activities stay inside the virtual environment.

Segmentation mirrors real enterprise architecture. In real organizations, endpoints, servers, and monitoring systems are logically separated to reduce lateral movement and contain incidents. My lab reflects this defensive design.

---

## 3. Lab Architecture Overview

The lab consists of multiple virtual machines, each representing a component of a small enterprise environment.

### Windows Endpoint  
Represents an employee workstation.  
This machine generates user activity such as browsing, downloading files, and running programs. It is the primary target for simulated attacks. Logs from this system are forwarded to the SIEM.

### Ubuntu Server  
Acts as a web or application server.  
It generates server-side logs and simulates backend services. It helps me understand server monitoring and log collection from Linux-based systems.

### SIEM Machine (Security Information and Event Management)  
This is the central monitoring system.  
It collects logs from endpoints and servers, normalizes them, and generates alerts. This is where I practice detection, log correlation, and alert analysis.

### Attacker Machine (Kali Linux or similar)  
Used to simulate real attack behavior.  
It performs scans, brute force attempts, payload delivery, and lateral movement simulations. This generates realistic logs that I can analyze from the defender perspective.

### Optional: Domain Controller  
If included, it simulates an Active Directory environment.  
This is important because many enterprise attacks target authentication systems. It allows me to practice detecting suspicious login behavior and privilege escalation.

### Interaction Between Machines

- The attacker machine sends traffic toward the Windows endpoint or server.
- The endpoint/server generates logs based on activity.
- Logs are forwarded to the SIEM.
- The SIEM processes and displays alerts.
- I investigate alerts from the defender perspective.

This flow mirrors real SOC operations: activity → logging → aggregation → detection → investigation.

---

## 4. Network Design

I configured the lab using NAT, Host-Only, or Internal networking depending on the role of the machines.

### Network Type Used

- Internal or Host-Only network for communication between lab machines.
- NAT adapter (optional) for internet access when updates are needed.

### Why This Network Design Was Chosen

Internal/Host-Only networking ensures:

- The lab machines can communicate with each other.
- They are isolated from my physical network.
- Attacks remain inside the lab.

NAT allows limited internet access without exposing internal machines directly to my real network.

### Traffic Flow

1. The attacker machine sends traffic to the target (Windows or Ubuntu).
2. The target processes the request and generates logs.
3. Logs are forwarded to the SIEM over the internal network.
4. The SIEM analyzes the data and generates alerts.

This controlled traffic flow allows me to observe how malicious activity appears in logs and how detection rules trigger.

### Importance of Isolation

Isolation is critical because:

- Simulated malware must not escape the lab.
- Network scans must not affect real devices.
- Misconfigurations should not expose my personal system.

In cybersecurity, containment is everything. The lab enforces this principle from the beginning.

---

## 5. Resource Allocation

Each VM requires careful CPU, RAM, and storage allocation.

Example allocation strategy:

- Windows Endpoint: Moderate RAM (4–8 GB), 2 CPUs  
- Ubuntu Server: 2–4 GB RAM, 1–2 CPUs  
- SIEM: Higher RAM (8+ GB if possible), multiple CPUs  
- Attacker Machine: 2–4 GB RAM  

The SIEM requires more resources because:

- Log indexing consumes memory.
- Searching logs requires CPU.
- Correlation rules need processing power.

If resources are under-allocated:

- Logs may drop.
- The SIEM may freeze.
- Performance bottlenecks distort learning results.

Proper allocation ensures realistic performance and reliable log ingestion.

Storage also matters. Logs grow quickly. Insufficient disk space can stop logging, which defeats the purpose of a SOC lab.

---

## 6. Learning Reflection

During setup, I faced challenges such as:

- Network misconfiguration between VMs.
- Inconsistent IP addressing.
- Resource exhaustion when running multiple machines.
- Log forwarding errors.

These challenges forced me to understand infrastructure more deeply. I learned that SOC work is not only about analyzing alerts. It requires knowledge of networking, operating systems, logging architecture, and system performance.

Building the lab taught me:

- How traffic actually flows between systems.
- Why log centralization is critical.
- How fragile infrastructure can be without proper planning.
- The importance of segmentation and isolation.

This setup process itself was a practical lesson in defensive architecture.

---

## Summary

This SOC lab environment forms the foundation of my detection and monitoring journey. By simulating endpoints, servers, attackers, and a centralized SIEM inside an isolated network, I created a controlled mini-enterprise.  

With this foundation, I can safely generate attacks, collect logs, analyze alerts, and improve my investigation skills. Instead of learning security passively, I now observe how events are created, transmitted, detected, and investigated in a realistic SOC workflow.
