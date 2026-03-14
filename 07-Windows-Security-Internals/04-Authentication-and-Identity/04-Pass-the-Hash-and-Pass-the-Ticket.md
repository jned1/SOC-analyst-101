# 04 - Pass-the-Hash and Pass-the-Ticket

## Overview

Credential-based attacks are among the most effective techniques used by attackers after gaining an initial foothold in a Windows environment. Instead of exploiting software vulnerabilities, attackers often focus on stealing authentication material from compromised systems and reusing it to move laterally across the network.

Two of the most well-known credential reuse techniques are **Pass-the-Hash (PtH)** and **Pass-the-Ticket (PtT)**. Both attacks exploit the way Windows stores and uses authentication artifacts during active user sessions.

These attacks are possible because Windows authentication mechanisms rely on reusable authentication data:

- NTLM password hashes used during NTLM authentication
- Kerberos tickets used in domain authentication

If an attacker gains access to these artifacts, they can impersonate users without knowing the original password. This makes identity theft one of the most powerful attack techniques in enterprise environments.

Understanding these attacks is critical for defenders because they are commonly used during lateral movement in Active Directory environments.

---

## Pass-the-Hash (PtH)

Pass-the-Hash is an attack technique that allows an attacker to authenticate to remote systems using a stolen NTLM password hash instead of the actual password.

### What an NTLM Hash Is

In Windows systems, passwords are not stored in plaintext. Instead, they are converted into cryptographic hash values using the NTLM hashing algorithm.

The hash represents the password in a non-reversible format and is stored in locations such as:

- Security Accounts Manager (SAM) database
- Active Directory
- LSASS memory during authenticated sessions

During NTLM authentication, the password hash is used to generate the challenge–response authentication message.

---

### Why the Hash Can Act as a Substitute for the Password

NTLM authentication relies on the password hash rather than the original password during the challenge–response exchange.

Because the hash is used directly in the authentication process, possession of the hash is sufficient to authenticate.

This means an attacker does not need to crack or reverse the hash. They only need to reuse it in an authentication request.

---

### Reusing Hashes Without Cracking Them

The key concept behind Pass-the-Hash is that the attacker injects a stolen NTLM hash into an authentication session.

The authentication process then proceeds as if the attacker possessed the correct password.

This allows attackers to bypass password knowledge entirely.

---

## Pass-the-Hash Attack Flow

A typical Pass-the-Hash attack follows a sequence of stages.

Initial compromise:

    Attacker gains access to a system
        -> often through phishing, malware, or exploitation

Credential dumping:

    Attacker accesses LSASS memory
        -> extracts authentication data

Hash extraction:

    NTLM password hashes are recovered
        -> belonging to logged-in users or administrators

Hash reuse:

    Attacker initiates authentication to another system
        -> using the stolen NTLM hash

If the compromised account has sufficient privileges, the attacker can gain access to additional systems.

---

## Security Impact of Pass-the-Hash

Pass-the-Hash attacks are extremely dangerous because they enable attackers to expand their access across the network.

### Lateral Movement

Attackers can authenticate to multiple systems using stolen hashes, allowing them to move from the initial compromised host to additional machines.

---

### Privilege Escalation

If the stolen hash belongs to a privileged account, the attacker may gain administrative control over additional systems.

---

### Domain Compromise

If domain administrator hashes are stolen, attackers can authenticate to domain controllers and potentially take full control of the Active Directory environment.

---

## Pass-the-Ticket (PtT)

Pass-the-Ticket is a credential reuse attack targeting Kerberos authentication rather than NTLM.

Kerberos authentication relies on tickets issued by the Key Distribution Center (KDC) after successful authentication.

Instead of password hashes, Kerberos uses cryptographically protected tickets that allow users to access services across the domain.

These tickets are stored in memory during active sessions and may be accessible through LSASS.

---

### Kerberos Ticket Granting Tickets (TGTs)

The Ticket Granting Ticket is issued after a user successfully authenticates with the domain controller.

The TGT proves the user's identity and allows the client to request additional service tickets without resending credentials.

---

### Service Tickets

Service tickets are issued for specific resources or services within the network.

These tickets allow the client to authenticate to the service without needing to provide a password again.

---

## Pass-the-Ticket Attack Flow

A Pass-the-Ticket attack typically follows these steps.

Initial system compromise:

    Attacker gains access to a system
        -> where users are actively authenticated

Ticket extraction:

    Kerberos tickets are extracted from LSASS memory

Ticket injection:

    Stolen tickets are injected into the attacker's session

Service authentication:

    Attacker accesses services
        -> using the injected Kerberos ticket

Because the ticket represents authenticated identity, the attacker can access resources without knowing the user's password.

---

## Differences Between PtH and PtT

Authentication Protocol

Pass-the-Hash targets NTLM authentication, while Pass-the-Ticket targets Kerberos authentication.

Credentials Used

Pass-the-Hash relies on NTLM password hashes.  
Pass-the-Ticket relies on Kerberos tickets.

Attack Prerequisites

Pass-the-Hash requires access to password hashes stored in memory or credential databases.  
Pass-the-Ticket requires access to Kerberos tickets stored in memory.

Typical Environments

Pass-the-Hash commonly appears in environments where NTLM authentication is still used.  
Pass-the-Ticket occurs primarily in Active Directory environments using Kerberos authentication.

---

## Detection and SOC Perspective

Detecting credential reuse attacks requires careful monitoring of authentication behavior across the network.

### Abnormal Authentication Patterns

Sudden authentication attempts from systems where a user normally does not log in may indicate credential reuse.

---

### Unusual Lateral Movement

Attackers often move rapidly between systems after obtaining authentication material.

Monitoring remote logons and administrative connections can reveal suspicious activity.

---

### Kerberos Ticket Misuse

Indicators may include abnormal service ticket requests or authentication from unexpected hosts using valid tickets.

---

### Suspicious Authentication Events

Windows security logs record authentication events that may reveal credential misuse.

Examples include:

- Unexpected administrative logons
- Authentication from non-standard systems
- Authentication activity inconsistent with user behavior

---

## Defensive Mitigations

Organizations deploy multiple defensive controls to reduce the risk of credential theft and reuse.

### Credential Guard

Credential Guard uses virtualization-based security to isolate authentication secrets from the operating system.

This prevents attackers from easily accessing credential material stored in LSASS.

---

### Restricting NTLM Usage

Reducing or disabling NTLM authentication significantly limits the effectiveness of Pass-the-Hash attacks.

Modern Active Directory environments prioritize Kerberos authentication instead.

---

### LSASS Protection

Running LSASS as a protected process helps prevent unauthorized processes from accessing LSASS memory.

---

### Privileged Access Management

Restricting the use of administrative accounts and limiting where privileged credentials are used reduces credential exposure.

---

### Limiting Credential Exposure on Endpoints

Administrative credentials should not be used on untrusted systems. Reducing credential exposure limits opportunities for attackers to capture authentication material.

---

## Key Takeaways

Pass-the-Hash and Pass-the-Ticket are among the most powerful credential theft techniques used by attackers in Windows environments.

These attacks exploit the fact that Windows authentication relies on reusable authentication artifacts stored in memory during active sessions.

NTLM password hashes and Kerberos tickets can both serve as substitutes for user credentials if attackers gain access to them.

Because these artifacts are often stored in LSASS memory, compromising LSASS can provide attackers with powerful authentication capabilities.

Successful use of these techniques enables attackers to move laterally within Active Directory environments, escalate privileges, and potentially compromise the entire domain.

For defenders, protecting credential storage mechanisms, limiting authentication artifact exposure, and monitoring authentication behavior are essential strategies for detecting and preventing identity-based attacks.