# Email Fundamentals

This document is part of my personal SOC analyst learning journey. The goal is to understand how email works at a technical level so I can analyze logs, detect abuse, and understand email-based attacks in real environments.

---

## 1. Why Email Exists

Email exists to enable digital communication between individuals and organizations across different networks. It allows users to send text, files, and structured information quickly and reliably.

In modern businesses, email is essential for:
- Internal communication between employees
- Communication with customers and partners
- Account registrations and password resets
- Legal and operational documentation

Businesses depend heavily on email because it integrates with identity systems, cloud services, ticketing systems, and collaboration tools.

Email is also one of the biggest cybersecurity targets because:
- It is publicly exposed to the internet
- It is trusted by users
- It allows file attachments and links
- It is commonly used for identity verification

Attackers use email to deliver phishing links, malware attachments, and impersonation campaigns. Since humans are part of the process, email remains a high-risk attack vector.

---

## 2. Core Email Components

Understanding email requires knowing the main systems involved in its operation.

### Mail User Agent (MUA)

The MUA is the email client used by the end user. Examples include Outlook, Thunderbird, or webmail interfaces.

The MUA allows users to:
- Compose emails
- Send emails
- Read and manage received messages

It is the user-facing part of the email system.

### Mail Transfer Agent (MTA)

The MTA is responsible for transferring email messages between servers.

When a message is sent, the MTA:
- Receives the message from the MUA
- Looks up the recipient domain
- Sends the message to the correct destination mail server

MTAs communicate using the SMTP protocol.

### Mail Delivery Agent (MDA)

The MDA delivers the email into the recipient’s mailbox.

Once the destination mail server receives the message, the MDA:
- Places it in the appropriate user mailbox
- Makes it available for retrieval

### DNS and MX Records

DNS (Domain Name System) translates domain names into IP addresses.

MX (Mail Exchange) records are special DNS records that:
- Tell the sending server which mail server is responsible for receiving email for a domain
- Provide priority if multiple mail servers exist

Without MX records, email servers would not know where to deliver messages.

---

## 3. Email Protocols

Email relies on specific network protocols for sending and retrieving messages.

### SMTP (Simple Mail Transfer Protocol)

SMTP is used for sending email.

It is responsible for:
- Sending email from MUA to MTA
- Sending email between mail servers (server-to-server communication)

Common ports:
- Port 25 (server-to-server)
- Port 587 (client submission)
- Port 465 (SMTPS, implicit TLS)

SMTP does not retrieve mail. It only pushes mail forward.

### POP3 (Post Office Protocol v3)

POP3 is used to retrieve emails from the server.

How it works:
- The client connects to the mail server
- Downloads messages
- Often deletes them from the server

Common ports:
- Port 110 (unencrypted)
- Port 995 (POP3 over TLS)

POP3 is simple but not ideal for multi-device access.

### IMAP (Internet Message Access Protocol)

IMAP is also used to retrieve email, but it keeps messages on the server.

How it differs from POP3:
- Emails remain stored on the server
- Multiple devices can synchronize the same mailbox
- Folder structure is maintained server-side

Common ports:
- Port 143 (unencrypted)
- Port 993 (IMAP over TLS)

IMAP is more common in enterprise environments.

### STARTTLS and Encryption

STARTTLS is a command that upgrades an existing unencrypted connection to an encrypted one using TLS.

TLS (Transport Layer Security) provides:
- Encryption of data in transit
- Protection against interception
- Integrity verification

Without encryption, email credentials and message contents could be intercepted during transmission.

---

## 4. The Email Journey (Step-by-Step Path)

Understanding the path of an email is important for detection and investigation.

1. The user clicks “Send” in their MUA.
2. The MUA connects to the organization’s SMTP server.
3. The SMTP server checks the recipient’s domain.
4. A DNS query is made to retrieve the MX record for the recipient domain.
5. The sending MTA connects to the recipient’s MTA using SMTP.
6. The receiving mail server accepts the message.
7. The MDA delivers the email into the recipient’s mailbox.
8. The recipient retrieves the message using IMAP or POP3.

Logs are generated at multiple points:
- On the sending SMTP server
- During DNS queries
- On the receiving mail server
- During mailbox access
- During authentication events

For a SOC analyst, these logs are critical for tracing suspicious activity.

---

## 5. Email Security Concepts

Modern email systems use authentication mechanisms to prevent spoofing and phishing.

### SPF (Sender Policy Framework)

SPF is a DNS record that specifies which mail servers are allowed to send email for a domain.

When a receiving server gets a message, it:
- Checks the sending IP address
- Verifies it against the domain’s SPF record

This helps reduce domain spoofing.

### DKIM (DomainKeys Identified Mail)

DKIM adds a digital signature to outgoing emails.

The receiving server:
- Verifies the signature using the public key stored in DNS
- Confirms the message was not modified in transit

DKIM ensures message integrity and domain authenticity.

### DMARC (Domain-based Message Authentication, Reporting, and Conformance)

DMARC builds on SPF and DKIM.

It allows domain owners to:
- Define policies (none, quarantine, reject)
- Receive reports about authentication failures

DMARC helps organizations reduce phishing by enforcing authentication rules.

---

## 6. SOC Perspective

From a SOC analyst perspective, email is a high-priority data source.

Important logs include:
- SMTP transaction logs
- Authentication logs
- Mail server connection logs
- SPF/DKIM/DMARC validation results
- Attachment scanning results

Common email-based attacks:
- Phishing (malicious links)
- Spoofing (fake sender identity)
- Business Email Compromise (BEC)
- Malware attachments
- Credential harvesting

Understanding how SMTP, DNS, and mailbox retrieval work helps detect:
- Suspicious sending patterns
- Unusual login activity
- Failed authentication attempts
- Abnormal email routing
- Spoofed domains

Without understanding protocol flow, it is difficult to trace the origin of malicious messages.

---

## Summary

Email is a complex system built on multiple components and protocols working together: MUAs, MTAs, MDAs, DNS, SMTP, IMAP, and POP3. Each stage of the email journey generates logs that are critical for security monitoring.

Security mechanisms like SPF, DKIM, and DMARC exist to reduce spoofing and phishing, but they must be properly configured and monitored.

By understanding how email functions technically, I can better analyze logs, investigate suspicious messages, and think like a SOC analyst defending real-world environments
