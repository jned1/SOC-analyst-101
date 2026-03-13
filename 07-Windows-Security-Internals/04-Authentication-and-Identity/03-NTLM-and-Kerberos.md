# 03 - NTLM and Kerberos

## Overview

Authentication protocols are responsible for verifying the identity of users, services, and systems attempting to access resources in a Windows environment. These protocols ensure that entities requesting access are who they claim to be before the operating system allows interaction with protected resources.

Authentication is distinct from authorization. Authentication confirms identity, while authorization determines what that authenticated identity is allowed to do. In Windows, authentication mechanisms validate credentials and generate security contexts, while authorization mechanisms evaluate permissions through access tokens and access control lists.

Windows environments support multiple authentication protocols to maintain compatibility with different network architectures, legacy systems, and varying security requirements. The two most important authentication protocols used in Windows are NTLM and Kerberos. Understanding both is critical for security professionals because attackers frequently target weaknesses in these protocols to steal credentials and move laterally within networks.

---

## NTLM Authentication

NTLM (NT LAN Manager) is a legacy authentication protocol used by Windows systems when Kerberos cannot be used. It was originally designed for early Windows networking environments before Active Directory existed.

NTLM remains present in modern Windows systems primarily for backward compatibility and for authentication scenarios where Kerberos is unavailable, such as workgroup environments or when communicating with non-domain systems.

NTLM uses a challenge–response authentication model. Instead of transmitting a plaintext password across the network, the client proves knowledge of the password by generating a cryptographic response derived from the password hash.

The NTLM protocol relies on password hashes stored in the Security Accounts Manager (SAM) database for local accounts or within Active Directory for domain accounts. When domain authentication is involved, domain controllers participate in validating the challenge–response exchange.

Because NTLM relies on password hashes rather than a centralized ticketing system, it has several architectural weaknesses that attackers frequently exploit.

---

## NTLM Authentication Flow (Step-by-Step)

The NTLM authentication process involves a sequence of messages exchanged between the client and the server.

Initial authentication request:

    Client -> Server
        NTLM negotiate message

The client begins authentication by informing the server that it supports NTLM authentication.

Challenge generation:

    Server -> Client
        NTLM challenge message

The server generates a random challenge value and sends it to the client. This challenge ensures that authentication responses are unique and prevents simple replay attacks.

Client response creation:

    Client -> Server
        NTLM authentication message

The client calculates a cryptographic response using the user's password hash and the challenge provided by the server. This response proves knowledge of the password without revealing the password itself.

Server validation:

    Server -> Domain Controller or Local SAM

The server sends the response to the domain controller or compares it locally using the Security Accounts Manager database.

If the calculated value matches the expected response, authentication is successful.

---

## Kerberos Authentication

Kerberos is the primary authentication protocol used in Active Directory environments. It was introduced to provide stronger security, improved scalability, and centralized authentication compared to NTLM.

Unlike NTLM, Kerberos uses a ticket-based authentication model. Instead of repeatedly sending password-derived authentication responses, users authenticate once and receive cryptographic tickets that allow them to access services throughout the domain.

Kerberos authentication is managed by the Key Distribution Center (KDC), which operates on domain controllers. The KDC consists of two logical services:

- Authentication Service (AS)
- Ticket Granting Service (TGS)

The Authentication Service verifies user credentials and issues a Ticket Granting Ticket (TGT). The Ticket Granting Service uses the TGT to issue service tickets that allow access to specific resources.

Because Kerberos uses encrypted tickets and mutual authentication, it provides stronger protection against credential interception and replay attacks compared to NTLM.

---

## Kerberos Authentication Flow (Step-by-Step)

Kerberos authentication involves multiple exchanges between the client and the Key Distribution Center.

Authentication Service Request (AS-REQ):

    Client -> KDC

The user attempts to log in and sends a request to the Authentication Service. This request identifies the user but does not include the password.

Authentication Service Response (AS-REP):

    KDC -> Client

The KDC verifies the user credentials and issues a Ticket Granting Ticket (TGT). The TGT is encrypted and can only be decrypted by the KDC.

Ticket Granting Ticket (TGT):

The TGT proves that the user has already been authenticated by the domain controller. It allows the client to request additional service tickets without resending credentials.

Ticket Granting Service Request (TGS-REQ):

    Client -> KDC

When the client wants to access a network service, it sends the TGT to the Ticket Granting Service and requests a service ticket for that resource.

Ticket Granting Service Response (TGS-REP):

    KDC -> Client

The KDC verifies the TGT and issues a service ticket for the requested service.

Service Ticket Usage:

    Client -> Service

The client presents the service ticket to the target service. The service validates the ticket and grants access without requiring the user's password.

---

## NTLM vs Kerberos Comparison

Security Design

NTLM relies on password hashes and challenge–response exchanges. Kerberos uses encrypted tickets issued by a trusted central authority.

Authentication Model

NTLM performs authentication directly between the client and server. Kerberos uses a centralized ticketing system managed by the Key Distribution Center.

Scalability

Kerberos is designed for large enterprise networks with centralized identity management. NTLM was designed for smaller environments and legacy compatibility.

Vulnerabilities

NTLM is more vulnerable to credential replay attacks, hash theft, and relay attacks. Kerberos offers stronger cryptographic protections but still has weaknesses if tickets are stolen.

Typical Use Cases

Kerberos is used for domain authentication within Active Directory environments. NTLM is used in legacy systems, workgroup networks, and fallback scenarios where Kerberos cannot operate.

---

## Security Implications

Authentication protocols are frequent targets for attackers because they provide a direct path to credential abuse and lateral movement.

NTLM Relay Attacks

In an NTLM relay attack, an attacker intercepts authentication messages and forwards them to another system to gain unauthorized access.

NTLM Hash Theft

If an attacker extracts NTLM password hashes from a compromised system, those hashes can be reused for authentication.

Kerberos Ticket Abuse

Kerberos relies on tickets stored in memory during active sessions. Attackers may attempt to steal these tickets and reuse them for authentication.

Kerberoasting

Kerberoasting is an attack where an attacker requests service tickets for service accounts and attempts to crack the encrypted ticket offline to recover the service account password.

Pass-the-Hash Attacks

Pass-the-Hash attacks involve using stolen NTLM password hashes to authenticate to other systems without knowing the original password.

Pass-the-Ticket Attacks

Pass-the-Ticket attacks involve stealing Kerberos tickets from memory and injecting them into another session to impersonate a user.

---

## Detection and SOC Perspective

Monitoring authentication protocols is essential for identifying identity-based attacks in enterprise environments.

Identifying Abnormal Authentication Patterns

Defenders monitor authentication logs for unusual login behavior such as logins from unexpected systems, unusual authentication times, or repeated authentication failures.

Suspicious NTLM Usage in Domain Environments

Modern Active Directory environments prefer Kerberos authentication. Excessive NTLM usage may indicate legacy misconfiguration or attacker activity attempting relay or credential reuse attacks.

Kerberos Ticket Abuse Indicators

Indicators of Kerberos abuse may include abnormal service ticket requests, unusually high numbers of ticket requests, or authentication patterns inconsistent with normal user behavior.

Monitoring Authentication Event Logs

Windows security logs record authentication events such as successful and failed logons, ticket requests, and authentication protocol usage. These logs provide critical evidence for investigating authentication-based attacks.

---

## Key Takeaways

NTLM and Kerberos are the two primary authentication protocols used in Windows environments.

NTLM uses a challenge–response model based on password hashes and remains present primarily for compatibility with legacy systems. Kerberos uses a centralized ticket-based authentication model designed for secure and scalable domain environments.

Understanding the architecture and behavior of these protocols is essential for defending against identity-based attacks. Attackers frequently exploit weaknesses in authentication systems to steal credentials, impersonate users, and move laterally within networks.

Techniques such as NTLM relay attacks, Pass-the-Hash, Pass-the-Ticket, and Kerberoasting all target weaknesses in authentication mechanisms.

For defenders, monitoring authentication patterns, identifying abnormal protocol usage, and analyzing authentication-related event logs are critical components of detecting credential theft and lateral movement within Windows environments.