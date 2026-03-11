# 01 - Windows Logon Architecture

## Overview

The Windows logon architecture defines how users authenticate to the operating system and how authenticated identities are translated into security contexts that allow interaction with system resources. This architecture coordinates multiple system components responsible for credential collection, authentication verification, session initialization, and security token generation.

Authentication represents one of the most critical security boundaries within Windows. It determines whether a user or system entity is permitted to establish a session and obtain an identity within the operating system.

It is important to distinguish between authentication and authorization.

Authentication is the process of verifying identity. It answers the question:

    "Who are you?"

Authorization determines what an authenticated identity is allowed to do. It answers the question:

    "What are you allowed to access?"

The Windows logon architecture is responsible for performing authentication and producing a security token that the system later uses to enforce authorization decisions.

---

## Core Components of the Logon Architecture

### Winlogon (winlogon.exe)

Winlogon is a critical Windows system process responsible for managing interactive logon sessions. It coordinates the secure attention sequence and handles tasks related to user authentication and session initialization.

Key responsibilities include:

- Managing user logon and logoff
- Launching the logon interface
- Starting user sessions after successful authentication
- Communicating with the Local Security Authority

Winlogon operates in user mode but performs highly privileged tasks that are essential for system security.

---

### LogonUI (LogonUI.exe)

LogonUI provides the graphical interface used during the logon process. It displays the credential prompt where users enter their authentication information.

LogonUI interacts with credential providers to collect user credentials in a secure manner.

Examples of interfaces handled by LogonUI include:

- Password input screens
- PIN authentication prompts
- Biometric authentication dialogs

LogonUI does not validate credentials itself; it simply collects them and passes them to the authentication system.

---

### Credential Providers

Credential Providers are modular components responsible for collecting authentication credentials from the user.

They define how credentials are entered and which authentication methods are supported. Different providers may support:

- Password-based authentication
- Smart card authentication
- Windows Hello authentication
- Biometric authentication

Credential providers package user credentials into a format that can be processed by the authentication subsystem.

---

### Local Security Authority Subsystem Service (lsass.exe)

The Local Security Authority Subsystem Service (LSASS) is the central authority responsible for enforcing authentication policies and validating user credentials.

LSASS performs several critical security functions:

- Validates user credentials
- Generates access tokens
- Enforces local security policies
- Interfaces with authentication packages
- Stores authentication session data

Because LSASS contains sensitive credential information, it is a primary target for attackers attempting to extract credentials from memory.

---

### Security Accounts Manager (SAM)

The Security Accounts Manager is a local database that stores account information for users on a standalone Windows system.

The SAM database contains:

- Usernames
- Password hashes
- Group membership information

During local authentication, LSASS consults the SAM database to validate user credentials.

On domain-joined systems, authentication may instead rely on domain controllers using Kerberos.

---

### Authentication Packages

Authentication packages are modules that implement specific authentication protocols. These packages operate within LSASS and are responsible for validating credentials using supported authentication mechanisms.

Examples include:

- NTLM authentication package
- Kerberos authentication package

Authentication packages interpret credential data and perform the appropriate verification process.

---

## Logon Flow (Step-by-Step)

The Windows logon process involves multiple coordinated steps.

### Step 1: User Enters Credentials

The user interacts with the logon interface and provides authentication information such as a username and password.

This information is captured through the graphical interface managed by LogonUI.

---

### Step 2: Credential Provider Captures Credentials

The credential provider collects the user credentials and prepares them for authentication.

Credentials are formatted and securely transmitted to the Local Security Authority for verification.

---

### Step 3: Authentication Package Validation

LSASS selects the appropriate authentication package based on the authentication type.

For example:

    Local account -> NTLM validation
    Domain account -> Kerberos validation

The authentication package performs protocol-specific verification.

---

### Step 4: LSASS Verification

LSASS verifies the credentials against the appropriate identity source.

Possible sources include:

- Local SAM database
- Domain controller
- External authentication services

If the credentials are valid, the authentication process continues.

---

### Step 5: Creation of the Access Token

After successful authentication, LSASS creates an access token representing the authenticated user.

The access token contains:

- User security identifier (SID)
- Group memberships
- Privileges assigned to the user
- Authentication information

This token becomes the identity representation for the user's session.

---

### Step 6: Session Creation and Environment Initialization

Winlogon receives the authenticated access token and creates the user's session.

The system then launches the user environment, including the desktop shell and user-specific services.

The access token is attached to processes created within the session, allowing the operating system to enforce authorization decisions.

---

## Logon Types in Windows

Windows supports multiple logon types depending on how authentication occurs.

### Interactive Logon

Interactive logon occurs when a user physically logs into a system through the console or local interface.

Example:

    User logs in from the workstation keyboard.

This type generates a full interactive user session.

---

### Network Logon

Network logon occurs when a user accesses resources over the network without initiating a local session.

Example:

    Accessing a shared file server.

No interactive desktop session is created.

---

### Remote Interactive Logon (RDP)

Remote interactive logon occurs when a user logs in remotely using Remote Desktop Protocol.

Example:

    Administrator connecting via RDP.

This creates a remote graphical session similar to a local interactive session.

---

### Service Logon

Service logon occurs when Windows services authenticate to run under specific service accounts.

Example:

    System services running under service identities.

These sessions operate without user interaction.

---

### Batch Logon

Batch logon occurs when scheduled tasks or automated processes execute using stored credentials.

Example:

    Scheduled task execution.

These sessions typically run without user interaction.

---

### Why SOC Analysts Care About Logon Types

Different logon types often indicate different types of activity.

For example:

- Remote interactive logons may indicate administrative access
- Network logons may indicate resource access
- Service logons may indicate background service activity

Abnormal logon patterns may reveal lateral movement or unauthorized access attempts.

---

## Authentication Packages

Windows supports multiple authentication mechanisms depending on the environment.

### NTLM

NTLM is a challenge-response authentication protocol used primarily for legacy compatibility and local authentication.

It relies on password hashes rather than transmitting plaintext passwords.

Although still supported, NTLM is considered weaker than modern authentication protocols.

---

### Kerberos

Kerberos is the primary authentication protocol used in Active Directory environments.

Kerberos relies on ticket-based authentication.

Basic flow:

    User authenticates
        -> Ticket granted
            -> Ticket used to access services

Kerberos allows secure authentication without repeatedly transmitting credentials.

---

### Local vs Domain Authentication

Local authentication occurs when credentials are validated against the local SAM database.

Domain authentication occurs when credentials are verified by a domain controller using Kerberos or NTLM.

Domain authentication enables centralized identity management and single sign-on capabilities.

---

## Security Implications

Attackers frequently target the Windows logon architecture to obtain or reuse credentials.

### Credential Harvesting

Malware may attempt to collect credentials entered by users during authentication.

This can involve keylogging or credential interception techniques.

---

### LSASS Memory Attacks

Because LSASS stores authentication session information, attackers often attempt to read LSASS memory to extract credentials or authentication tokens.

Credential dumping tools frequently target this process.

---

### Pass-the-Hash

Pass-the-Hash attacks reuse stolen NTLM password hashes to authenticate without knowing the original password.

Attackers inject the hash into an authentication session to impersonate a user.

---

### Pass-the-Ticket

Pass-the-Ticket attacks involve stealing Kerberos tickets from memory and reusing them to authenticate to other systems.

This technique allows attackers to move laterally across a network.

---

### Credential Replay Attacks

Attackers may capture authentication material and reuse it to impersonate users across systems.

This can lead to unauthorized access and privilege escalation.

---

## Detection and SOC Perspective

Defenders monitor authentication activity to identify suspicious behavior.

Windows security logs contain authentication events that reveal:

- Successful logons
- Failed authentication attempts
- Logon types
- Source systems

SOC analysts often investigate:

Abnormal Logon Patterns

Examples include logins occurring at unusual times or from unusual systems.

Suspicious Authentication Attempts

Repeated failed logons may indicate password guessing or brute-force attacks.

Lateral Movement Indicators

Attackers moving across systems often generate sequences of network or remote interactive logons.

Analyzing authentication telemetry allows defenders to identify compromised credentials and unauthorized access attempts.

---

## Key Takeaways

The Windows logon architecture coordinates multiple system components responsible for credential collection, authentication validation, and session creation.

Processes such as Winlogon, LogonUI, credential providers, and LSASS work together to authenticate users and establish secure sessions.

Authentication packages such as NTLM and Kerberos enable Windows to support multiple identity verification mechanisms.

Because authentication defines system identity, it represents a critical security boundary.

Attackers frequently target this architecture through credential harvesting, LSASS memory attacks, and authentication replay techniques.

Understanding how Windows performs authentication allows security analysts to detect abnormal logon behavior, investigate credential-based attacks, and identify indicators of lateral movement within enterprise environments.