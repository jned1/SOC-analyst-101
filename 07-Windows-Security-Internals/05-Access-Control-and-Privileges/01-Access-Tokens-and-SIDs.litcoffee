# 01 - Access Tokens and SIDs

## Overview

Windows enforces security primarily through identity-based access control. Every action performed by a user, service, or application is evaluated based on the identity associated with that entity. Two fundamental elements enable this model: **Security Identifiers (SIDs)** and **Access Tokens**.

Security Identifiers uniquely represent users, groups, and security principals within Windows. Access tokens represent the **active security context** of a process or thread after authentication.

When a user logs into Windows, the operating system creates an access token containing the user's SID, group memberships, and assigned privileges. Every process started by that user inherits this token. When a process attempts to access a protected resource, Windows evaluates the token against the resource's Access Control List (ACL) to determine whether access should be granted.

Because access tokens define the privileges and identity of executing processes, they are central to Windows security enforcement. Attackers frequently attempt to manipulate or steal tokens to elevate privileges or impersonate other users.

---

## Security Identifiers (SIDs)

A **Security Identifier (SID)** is a unique value used by Windows to identify security principals such as users, groups, and computer accounts. Instead of referencing accounts by name, Windows internally uses SIDs to track identity and enforce permissions.

SIDs remain consistent even if the associated account name changes. This ensures that access control rules remain valid regardless of account renaming.

---

### Structure of a SID

A SID is represented as a string composed of multiple numeric components.

Example SID:

    S-1-5-21-3623811015-3361044348-30300820-1013

Each component provides information about the identity authority and specific account.

---

### Components of a SID

A SID contains several fields that define its structure:

Revision  
The version of the SID format. Most Windows systems use revision 1.

Identifier Authority  
Specifies the authority that issued the SID. For example, value 5 represents the Windows NT Authority.

Sub-authorities  
A series of numbers that define the domain or local computer identifier.

Relative Identifier (RID)  
The final value uniquely identifies the specific user or group within a domain or local system.

Example breakdown:

    S-1-5-21-3623811015-3361044348-30300820-1013
      | | |------------------------------|  |
      | |            Domain ID           |  RID
      | Identifier Authority
      Revision

---

### Examples of Common SIDs

Certain SIDs are standardized across all Windows systems.

Examples include:

Local System

    S-1-5-18

Administrators group

    S-1-5-32-544

Everyone group

    S-1-1-0

Authenticated Users

    S-1-5-11

These identifiers allow the operating system to consistently reference common accounts and groups.

---

### Built-in Groups and Well-Known SIDs

Windows includes predefined groups that perform administrative or system functions. These groups are identified using well-known SIDs.

Examples include:

Administrators  
Users  
Guests  
Backup Operators  
Remote Desktop Users

Security policies and access control entries frequently reference these SIDs rather than account names.

---

### Relationship Between SIDs and Windows Accounts

Every Windows account, whether local or domain-based, is assigned a SID when it is created.

Key characteristics:

- SIDs are unique within a security domain.
- A deleted account's SID is never reused.
- Permissions assigned to resources reference SIDs rather than account names.

This design ensures that access control remains consistent even if user accounts are renamed or modified.

---

## Access Tokens

An **Access Token** represents the security context of a logged-in user or running service. It contains identity and privilege information used by Windows to enforce security decisions.

Whenever a user successfully authenticates, the Local Security Authority Subsystem Service (LSASS) generates an access token for that session.

The access token contains information describing the user's identity, group memberships, and privileges. All processes launched by the user inherit this token.

---

### Token Creation During Logon

The token creation process occurs during authentication.

Simplified process:

    User authentication
        -> Credentials verified by LSASS
            -> User and group SIDs retrieved
                -> Privileges assigned
                    -> Access token created

This token becomes the user's security identity for the session.

---

### Association Between Tokens and Processes

Every process in Windows runs under an access token.

Key relationships:

- A **primary token** is attached to processes.
- Threads within a process may temporarily use **impersonation tokens**.
- Child processes inherit tokens from their parent process.

Because tokens define permissions, any code running within a process inherits the privileges contained in the token.

---

### How Windows Uses Tokens During Access Checks

When a process attempts to access a protected resource such as a file or registry key, Windows performs an access check.

The system compares:

- The SIDs present in the access token
- The Access Control List (ACL) attached to the resource

If the token satisfies the ACL rules, access is granted.

---

## Components of an Access Token

Access tokens contain several fields used during security decisions.

---

### User SID

The User SID uniquely identifies the account associated with the token.

This SID represents the primary identity of the token owner.

---

### Group SIDs

Access tokens also contain SIDs for all groups to which the user belongs.

These groups may include:

- Local groups
- Domain groups
- Built-in security groups

Group membership often grants additional permissions.

---

### Privileges

Privileges define system-level rights granted to the token.

Examples include:

- SeDebugPrivilege
- SeBackupPrivilege
- SeShutdownPrivilege

Privileges allow processes to perform sensitive system operations.

---

### Default DACL

The Default Discretionary Access Control List defines the default security permissions assigned to new objects created by the process.

For example, when a process creates a file, the default DACL influences the initial access permissions.

---

### Integrity Level

Integrity levels are part of Windows Mandatory Integrity Control.

They represent trust levels assigned to processes.

Common levels include:

- Low
- Medium
- High
- System

Processes with lower integrity cannot modify objects belonging to higher integrity levels.

---

### Token Type

Two primary token types exist:

Primary Token  
Used by processes to define their security context.

Impersonation Token  
Used by threads to temporarily act as another security principal.

Impersonation tokens allow services to perform actions on behalf of users.

---

## Access Check Process

When a process attempts to access a protected resource, Windows performs an access evaluation.

The process involves multiple components within the Windows security architecture.

Simplified flow:

    Process requests resource
        -> Security Reference Monitor invoked
            -> Token SIDs compared with resource ACL
                -> Permissions evaluated
                    -> Access granted or denied

---

### Interaction Between Tokens and Access Control Lists

Resources in Windows contain Access Control Lists (ACLs) defining which SIDs have permission to access them.

The access token provides the identity information used during this comparison.

If a SID in the token matches an entry in the ACL granting the requested permission, access is allowed.

---

### Role of the Security Reference Monitor (SRM)

The Security Reference Monitor is a kernel component responsible for enforcing access control decisions.

It evaluates access requests by examining:

- Access tokens
- Security descriptors
- ACL entries

This mechanism ensures that only authorized identities can access protected resources.

---

## Security Implications

Access tokens are critical for enforcing privilege boundaries in Windows.

Because tokens represent active identities and privileges, compromising a token can allow attackers to impersonate legitimate users or elevate privileges.

Attackers frequently target access tokens after gaining initial system access.

---

### Token Abuse in Attacks

If an attacker obtains a token belonging to a privileged account, they can execute commands or access resources using that identity.

This can allow attackers to bypass authentication entirely.

---

### Token Impersonation Techniques

Certain Windows APIs allow processes to impersonate other users.

Attackers may abuse these mechanisms to assume the identity of higher-privileged accounts.

---

### Token Theft During Credential Dumping

Credential dumping attacks targeting LSASS may expose authentication artifacts including access tokens.

These tokens can be reused to access additional systems.

---

## Attack Techniques Involving Tokens

Several attack techniques involve manipulation or reuse of access tokens.

---

### Token Impersonation

Token impersonation allows a process to temporarily adopt the identity associated with another token.

If attackers can obtain a privileged token, they may impersonate that identity.

---

### Token Duplication

Attackers may duplicate existing tokens from running processes.

Duplicated tokens can then be used to launch new processes with the same privileges.

---

### Privilege Escalation Through Token Manipulation

If a system process holds a highly privileged token, attackers may attempt to capture or reuse it to escalate privileges.

---

### Pass-the-Token Concepts

Pass-the-Token attacks involve reusing captured tokens to authenticate as another user without needing credentials.

This concept is similar to other credential reuse attacks but targets token-based authentication artifacts.

---

## Defensive and SOC Perspective

Monitoring token usage is important for detecting privilege escalation and lateral movement activity.

---

### Detecting Abnormal Privilege Usage

Unusual use of high-risk privileges such as debugging or system-level privileges may indicate malicious activity.

---

### Monitoring Token-Related Activity

Security monitoring tools can detect attempts to manipulate or impersonate tokens.

Examples include:

- Suspicious process behavior
- Unauthorized token duplication
- Unexpected privilege escalation

---

### Indicators of Token Impersonation

Indicators may include processes running under unexpected identities or processes acquiring privileges not normally associated with their role.

---

### Relationship to Event Logs and Authentication Events

Windows security logs provide visibility into authentication activity and privilege usage.

Correlating authentication events with process activity helps identify token abuse scenarios.

---

## Key Takeaways

Access tokens represent the security identity of processes and define what actions those processes are allowed to perform.

Security Identifiers uniquely identify users, groups, and other security principals within Windows systems.

When a process attempts to access a protected resource, Windows evaluates the SIDs contained in its access token against the Access Control List associated with the resource.

Because tokens contain privileges and group memberships, they play a central role in privilege enforcement and access control.

Attackers frequently target tokens during privilege escalation and lateral movement operations. Techniques such as token impersonation, duplication, and token theft allow attackers to reuse legitimate identities without authenticating again.

Understanding how tokens and SIDs interact with Windows access control mechanisms is essential for detecting identity-based attacks and investigating suspicious activity in enterprise environments.