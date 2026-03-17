# 03 - UAC and Integrity Levels

## Overview

User Account Control (UAC) is a security feature in Windows designed to enforce the principle of **least privilege**. It ensures that users and applications operate with the minimum level of access required, even when the user is a member of the Administrators group.

In Windows, there is a distinction between:

- **Standard user context**: Limited privileges, cannot perform system-level changes
- **Administrator context**: Elevated privileges, can modify system settings and security controls

UAC reduces the risk of accidental or unauthorized system changes by requiring explicit approval before granting elevated privileges.

---

## UAC Architecture

UAC is implemented through a combination of token filtering, controlled elevation, and user interaction mechanisms.

---

### Split Token Model

When an administrator logs into Windows, two access tokens are created:

- **Filtered token (standard user token)**
- **Full administrator token**

The filtered token removes high-risk privileges and administrative SIDs. This token is used for normal operations.

The full token contains all administrative privileges but is not used unless explicitly requested.

---

### Consent and Credential Prompts

When an application requests elevation:

- If the user is an administrator → **Consent prompt**
- If the user is a standard user → **Credential prompt**

This ensures that elevation requires explicit user interaction.

---

### Secure Desktop

UAC prompts are displayed on a protected interface known as the **Secure Desktop**.

Characteristics:

- Isolated from normal user processes
- Prevents malware from interacting with the prompt
- Ensures trusted input handling

---

### Elevation Process

The elevation process transitions a process from a filtered token to a full administrative token.

Simplified flow:

    Application requests elevation
        -> UAC prompt displayed
            -> User approves request
                -> New process created with elevated token

The elevated process runs with full administrative privileges.

---

## Access Tokens and UAC

UAC directly modifies how access tokens are used and enforced.

---

### Token Filtering

For administrator accounts, the initial access token is filtered:

- Administrative privileges are removed or disabled
- Administrative group SIDs are marked as deny-only

This ensures that even administrators operate in a limited context by default.

---

### Changes During Elevation

When elevation occurs:

- Full administrative token is used
- All privileges are available
- Administrative SIDs are enabled

This transition significantly increases the capabilities of the process.

---

### Role of Privileges in Elevated vs Non-Elevated Processes

Non-elevated processes:

- Limited privileges
- Restricted system access

Elevated processes:

- Full privilege set
- Ability to modify system configurations, drivers, and security settings

---

## Integrity Levels Explained

Integrity Levels are part of **Mandatory Integrity Control (MIC)** and provide an additional layer of access control based on trust levels.

---

### What Integrity Levels Are

Integrity Levels classify processes and objects based on trust.

They define **who can modify whom**, independent of traditional permissions.

---

### Mandatory Integrity Control (MIC)

MIC enforces rules such as:

    Lower integrity process cannot modify higher integrity object

This prevents untrusted code from interfering with more trusted processes.

---

### Integrity Levels

Low Integrity:

- Used by sandboxed applications (e.g., browsers in restricted mode)
- Cannot modify medium or high integrity objects

Medium Integrity:

- Default level for standard user processes

High Integrity:

- Assigned to elevated processes
- Full administrative access

System Integrity:

- Used by core system processes (e.g., LSASS, services)
- Highest level of trust

---

### Isolation Enforcement

Integrity Levels enforce isolation as follows:

- Low → cannot write to Medium/High
- Medium → cannot write to High
- High → can modify Medium and Low

This creates a hierarchical trust model within the system.

---

## Interaction Between UAC and Integrity Levels

UAC and Integrity Levels work together to enforce privilege boundaries.

---

### Elevation and Integrity Changes

When a process is elevated:

- Integrity level increases from **Medium → High**
- Privileges increase via full token access

---

### High vs Low Integrity Behavior

High-integrity processes:

- Can interact with and modify lower-integrity processes

Low-integrity processes:

- Restricted from modifying higher-integrity objects
- Limited ability to affect system behavior

---

### Security Boundary Reinforcement

Even if permissions allow access, integrity levels can still block operations if trust levels are violated.

This provides an additional enforcement layer beyond ACLs.

---

## Security Implications

UAC is not considered a strict security boundary, but it is a critical defense mechanism against accidental or unauthorized privilege escalation.

---

### Why UAC Matters

UAC:

- Reduces attack surface by limiting default privileges
- Forces explicit elevation for sensitive actions
- Adds friction to privilege escalation attempts

---

### UAC Bypass Techniques (Conceptual)

Attackers attempt to bypass UAC to gain elevated privileges without user interaction.

Common techniques include:

- Abuse of auto-elevated binaries
- Exploiting trusted system applications
- Manipulating registry or environment configurations

---

### Token Manipulation and Privilege Escalation

Attackers may attempt to:

- Replace or duplicate tokens
- Inject into elevated processes
- Trigger elevation indirectly

These techniques allow attackers to bypass normal UAC workflows.

---

## Real-World Abuse Scenarios

---

### Misconfigured Applications

Applications configured to auto-elevate without proper validation may allow attackers to execute code with elevated privileges.

---

### Silent UAC Bypass

Some techniques avoid triggering visible prompts by leveraging trusted system components.

---

### Persistence via Elevated Processes

Attackers may establish persistence by executing code within high-integrity processes, ensuring continued elevated access.

---

## Defensive and SOC Perspective

Understanding UAC behavior is essential for detecting privilege escalation attempts.

---

### Detecting Abnormal Elevation Behavior

Indicators include:

- Unexpected elevation prompts
- Processes requesting elevation outside normal workflows
- Elevated processes spawned by unusual parents

---

### Monitoring Process Integrity Levels

Security tools can track integrity levels of processes.

Suspicious patterns include:

- Rapid transition from medium to high integrity
- Non-administrative processes running at high integrity

---

### Suspicious Parent-Child Relationships

Examples:

- Office applications spawning elevated command shells
- Browsers launching high-integrity processes

These patterns may indicate exploitation or UAC bypass attempts.

---

### Identifying UAC Bypass Patterns

Indicators include:

- Execution of known auto-elevated binaries
- Registry modifications affecting elevation behavior
- Unexpected elevated processes without user interaction

---

## Key Takeaways

User Account Control enforces least privilege by ensuring that even administrators operate with restricted tokens by default.

Integrity Levels provide an additional layer of isolation by preventing lower-trust processes from modifying higher-trust processes.

Elevation increases both privileges and integrity level, allowing processes to perform sensitive system operations.

Although UAC is not a strict security boundary, bypassing it is often a critical step in privilege escalation attacks.

Monitoring process elevation behavior, integrity levels, and token usage is essential for detecting privilege escalation and understanding attacker activity in Windows environments.