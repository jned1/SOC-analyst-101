# Virtual Machine Installation – SOC Lab

## 1. Purpose of Installing a Virtual Machine

Before installing any operating system (Windows or Ubuntu), the foundation of a SOC lab is virtualization. A virtual machine (VM) allows me to simulate enterprise systems inside my physical laptop without risking my host operating system.

From a SOC perspective, virtualization is essential because:

- Security testing involves risky behavior (malware simulation, scans, brute force attempts).
- Systems must be isolated to prevent unintended spread.
- Analysts need multiple machines running simultaneously.

A VM behaves like a real computer with its own CPU, memory, disk, and network interface. This allows realistic attack and detection scenarios while maintaining containment.

The VM layer is the infrastructure backbone of the SOC lab.

---

## 2. Choosing the Hypervisor

I selected a desktop hypervisor such as VirtualBox or VMware Workstation.

A hypervisor is software that allows multiple operating systems to run on one physical machine.

This choice matters because:

- It supports network segmentation between lab machines.
- It allows snapshot functionality (critical for rollback after attacks).
- It enables resource control per machine.
- It isolates lab environments from the host OS.

From a SOC training perspective, snapshots are extremely valuable. After simulating an attack, I can revert to a clean state without reinstalling everything. This encourages experimentation.

---

## 3. Creating the Virtual Machine

When creating the VM, I defined:

- Name of the machine (e.g., WIN-CLIENT01 or UBUNTU-SERVER01)
- Operating system type
- Resource allocation (CPU, RAM)
- Virtual disk size

Naming matters in a SOC lab because:

- Logs reference hostnames.
- SIEM dashboards display system identifiers.
- Clear naming improves investigation efficiency.

Proper VM identification reflects enterprise asset management practices.

---

## 4. Resource Allocation Decisions

### CPU Allocation

I assigned 1–2 CPU cores (or more depending on role).

Why this matters:

- Insufficient CPU causes lag and unrealistic system behavior.
- Over-allocation may starve other VMs.
- SOC monitoring tools require processing power to generate logs properly.

Balanced CPU allocation ensures realistic system performance.

---

### RAM Allocation

RAM allocation depends on the OS role:

- Endpoint VM: 4–8 GB
- Server VM: 2–4 GB
- SIEM VM: 8+ GB

Memory impacts:

- Log generation stability
- System responsiveness
- Tool reliability

If RAM is too low, logging services may fail silently. That creates blind spots in monitoring.

---

### Disk Allocation

I configured a dynamically allocated virtual disk (e.g., 40–80 GB).

Disk size is important because:

- Logs grow over time.
- Updates consume storage.
- Forensic artifacts require space.

In SOC environments, disk exhaustion can stop log collection. Preventing that issue starts at VM creation.

---

## 5. Network Configuration

During VM creation, I selected the appropriate network mode:

- Internal Network or Host-Only for lab isolation
- NAT (optional) for internet access

Why this matters:

Internal or Host-Only networking allows:

- Communication between lab machines
- Controlled attack simulation
- Isolation from the physical network

Isolation prevents:

- Accidental scanning of real devices
- Malware escape
- Legal or operational risks

In real enterprises, segmentation limits attacker movement. My VM network design mirrors that principle.

---

## 6. Enabling Virtualization Features

I ensured:

- Hardware virtualization is enabled in BIOS/UEFI.
- Virtualization extensions (VT-x / AMD-V) are active.
- Guest additions or tools are installed after OS installation.

These features improve:

- System performance
- Screen resolution handling
- Clipboard integration
- Network stability

Stable performance ensures logs and monitoring tools function reliably.

---

## 7. Snapshot Configuration

After creating the base VM (before installing risky tools), I created a clean snapshot.

Snapshots are critical in SOC training because:

- Attacks can permanently modify systems.
- Malware simulation may corrupt configurations.
- Recovery should be fast and repeatable.

Snapshots allow controlled experimentation without rebuilding infrastructure from scratch.

This mirrors disaster recovery concepts in enterprise environments.

---

## 8. Learning Reflection

Installing the VM made me realize that infrastructure design is part of security. A SOC analyst is not only someone who reads alerts; they must understand:

- How systems are provisioned
- How network segmentation works
- How isolation prevents lateral damage
- How resource limits affect logging reliability

The hypervisor is invisible in daily SOC operations, but it defines the architecture of the lab. If the foundation is weak, monitoring results become unreliable.

---

## Summary

Installing the virtual machine is the foundational step of my SOC lab. It creates isolated, controllable environments where endpoints, servers, and attackers can interact safely. Proper resource allocation, network segmentation, and snapshot management ensure realistic behavior and safe experimentation.  

This VM layer supports all future monitoring, logging, detection, and incident response activities within the SOC lab environment.
