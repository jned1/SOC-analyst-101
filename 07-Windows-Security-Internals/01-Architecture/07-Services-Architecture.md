# 07-Services-Architecture.md

## Overview

### What Windows Services Are

Windows Services are long-running executable components designed to operate in the background without direct user interaction. They typically start at boot or on demand and provide core operating system functionality such as networking, authentication, logging, update management, and security enforcement.

Services are managed centrally and execute under specific security contexts defined by the operating system.

### Difference Between Services and Regular User Applications

| Characteristic        | Windows Service                    | User Application                |
|----------------------|------------------------------------|----------------------------------|
| User Interaction     | No interactive UI (Session 0)      | Interactive desktop session     |
| Startup Mechanism     | Managed by Service Control Manager | Started by user or shell        |
| Privilege Context     | Often high-privilege accounts      | User-level token                |
| Lifetime              | Long-running                      | User session dependent          |

Services operate in Session 0, isolated from user sessions, which reduces direct interaction but increases security sensitivity.

### Why Services Are Critical to System Functionality

Core Windows components depend on services:

- Authentication (e.g., LSASS)
- Network stack
- Windows Update
- Event logging
- Endpoint security agents

Compromise of a privileged service can result in full system compromise.

---

## Service Control Manager (SCM)

### Role of services.exe

The Service Control Manager (SCM) is implemented in:

    services.exe

SCM is responsible for:

- Reading service configuration from the Registry
- Launching service processes
- Managing service state transitions
- Enforcing service security descriptors
- Handling service dependencies

SCM itself runs as LocalSystem and is a high-value security target.

### How Services Are Registered

Services are registered in the Registry under:

    HKLM\SYSTEM\CurrentControlSet\Services\<ServiceName>

Configuration includes:

- ImagePath
- Start type
- Service type
- ObjectName (account)
- Failure actions
- Security descriptor

Registration is typically performed via:

    sc create
    CreateService() API

### How Services Are Started, Stopped, and Managed

SCM exposes control operations:

- StartService()
- ControlService()
- QueryServiceStatus()

Service states:

- SERVICE_STOPPED
- SERVICE_START_PENDING
- SERVICE_RUNNING
- SERVICE_PAUSED

### Boot-Time vs Demand-Start Services

Start types include:

- Boot (loaded by boot loader)
- System (loaded by kernel during initialization)
- Automatic (started by SCM at boot)
- Manual (started on demand)
- Disabled

Boot and System services often include drivers and security-critical components.

---

## Service Architecture

### Service Types

1. Own Process
   Service runs in its own executable:

       type= own

2. Shared Process
   Service hosted within a shared process such as:

       svchost.exe

### svchost.exe and Service Grouping

svchost.exe hosts multiple services grouped by functionality to reduce resource usage.

Grouping is defined in:

    HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost

Security implication:
Compromise of one hosted service may impact others within the same svchost instance.

### Service Accounts

Common service accounts:

- LocalSystem (high privilege, full system access)
- LocalService (limited local privileges)
- NetworkService (limited local, network credentials)
- Custom domain/local accounts

Security risk increases with excessive privilege assignment.

### Service Permissions and Security Descriptors

Each service has a security descriptor defining:

- Who can start/stop it
- Who can reconfigure it
- Who can delete it

Permissions are enforceable via:

    sc sdshow <ServiceName>

Weak permissions enable privilege escalation.

---

## Service Lifecycle

### Service States

- Stopped
- Start Pending
- Running
- Pause Pending
- Paused
- Stop Pending

### Interaction with SCM

Services communicate status updates to SCM using:

    SetServiceStatus()

Failure to report correct status may cause SCM to terminate or restart the service.

### Dependency Management

Services may depend on:

- Other services
- Service groups

Dependency failures prevent startup, which attackers may abuse to disable security services.

---

## Security Model of Windows Services

### Service Access Control

Access rights include:

- SERVICE_START
- SERVICE_STOP
- SERVICE_CHANGE_CONFIG
- DELETE

Improperly configured DACLs allow unprivileged users to modify service configuration.

### Service Configuration Storage

Service definitions stored in the Registry represent a key attack surface.

Critical values:

    ImagePath
    ObjectName
    FailureActions

Registry write access enables persistence or escalation.

### Token Usage and Privilege Context

When SCM launches a service:

- A primary token is created
- Privileges are assigned based on the service account
- Integrity level typically High or System

Compromising a LocalSystem service grants:

- SeDebugPrivilege
- SeTcbPrivilege
- Full system control

### Integrity Levels and Isolation

Services run in Session 0 isolation.

They are protected from direct user session interaction, but token misuse or privilege abuse can bypass isolation.

---

## Common Service Misconfigurations

### Unquoted Service Paths

Example:

    C:\Program Files\Vulnerable Service\service.exe

If unquoted, Windows may interpret:

    C:\Program.exe

Attackers place malicious executables in earlier path segments.

### Weak Service Permissions

If low-privilege users can:

- Modify configuration
- Change binary path

Privilege escalation becomes trivial.

### Writable Service Binaries

If service executable is writable by Users:

    Replace binary → Restart service → SYSTEM execution

### Weak Registry Permissions

Writable keys under:

    HKLM\SYSTEM\CurrentControlSet\Services

Enable persistence or hijacking.

### Insecure Service Accounts

Using LocalSystem unnecessarily increases attack impact.

---

## Attack Techniques Involving Services

### Service-Based Persistence

Creating a malicious service:

    sc create backdoor binPath= C:\malware.exe start= auto

Ensures execution at boot.

### Privilege Escalation via Service Misconfiguration

Steps:

1. Identify modifiable service
2. Change ImagePath
3. Restart service
4. Execute payload as SYSTEM

### Service Binary Replacement

Replace writable service binary and wait for restart.

### DLL Hijacking via Services

If service loads DLL from insecure location:

- Place malicious DLL in search path
- Trigger service restart

### Abusing svchost Grouping

If attacker controls one service in shared svchost:

- Code injection into host process
- Potential lateral service impact

---

## Detection and Defensive Perspective (SOC Focus)

### Monitoring Service Creation (Event ID 7045)

Windows logs new service installation:

    Event ID 7045 – Service installed

Critical fields:

- Service Name
- Image Path
- Account

Unexpected auto-start services are high priority alerts.

### Registry Monitoring for Service Changes

Monitor modifications under:

    HKLM\SYSTEM\CurrentControlSet\Services

Key changes:

- ImagePath
- ObjectName
- FailureActions

### Detecting Suspicious Service Accounts

Red flags:

- Services running as Domain Admin
- Services using user accounts
- Privileged services recently modified

### Abnormal Service Restarts

Repeated restarts may indicate:

- Crashing malicious service
- Brute-force tampering
- Evasion attempts

### Correlating Service Activity with Process Trees

Investigate:

- Parent process creating service
- Command line arguments
- Token integrity
- Subsequent child processes

Service abuse often correlates with:

- Lateral movement
- Privilege escalation chains
- Persistence mechanisms

---

## Key Takeaways

- Services are high-privilege execution points.
- The Service Control Manager orchestrates all service activity and represents a critical trust boundary.
- Misconfiguration equals privilege escalation risk.
- Service creation and modification are strong persistence indicators.
- Monitoring Event ID 7045 and Registry changes is essential for SOC operations.
- Understanding service architecture allows defenders to trace privilege abuse from configuration to execution.

Windows Services sit at the intersection of architecture and security. Mastery of their internal operation enables analysts to detect persistence, privilege escalation, service hijacking, and enterprise-wide compromise paths with precision.