# Email Threat Analysis Workflow

## 1. Objective

The objective of email threat analysis in a SOC environment is to determine whether a suspicious email represents a real security threat, assess potential impact, and take appropriate containment actions.

In practice, this means:

- Validating sender authenticity
- Analyzing embedded URLs and attachments
- Identifying social engineering tactics
- Correlating email activity with authentication and endpoint logs
- Determining user impact
- Producing a clear and defensible verdict

Email analysis is not just about classifying a message as malicious or benign. It is about understanding attacker intent, identifying indicators of compromise, and preventing lateral movement or account takeover.

---

## 2. Email Investigation Workflow Overview

When a suspicious email is reported or detected by a security control, I follow this structured workflow:

1. Initial Triage  
   - Confirm alert source (user report, email gateway, SIEM)
   - Identify recipient(s)
   - Preserve original message and headers

2. Header & Authentication Analysis  
   - Review SPF, DKIM, and DMARC results  
   - Inspect Return-Path and Reply-To  
   - Examine sending IP and mail relay chain  

3. Content & Social Engineering Review  
   - Evaluate urgency, tone, impersonation indicators  
   - Identify suspicious links or attachments  

4. URL or Attachment Analysis  
   - Extract and inspect URLs  
   - Perform static analysis of attachments  
   - Submit suspicious files or links to sandbox  

5. Post-Delivery Activity Review  
   - Check if the user clicked or opened attachment  
   - Review authentication logs for suspicious logins  
   - Inspect mailbox rule creation or forwarding  

6. Verdict & Documentation  
   - Classify severity  
   - Extract IOCs  
   - Document findings  
   - Recommend containment and preventive measures  

This structured process ensures consistency and reduces the risk of oversight.

---

## 3. Scenario 1 – Phishing Email (Credential Harvesting)

### Email Overview

Sender: Microsoft Security <security-alert@micr0soft-support.com>  
Subject: Urgent: Suspicious Sign-in Attempt Detected  
Return-Path: alert@micr0soft-support.com  
SPF: Fail  
DKIM: None  
DMARC: Fail  

Body Content:

"We detected an unusual login attempt from Russia. Verify your account immediately to prevent suspension."

Embedded URL:

http://login-microsoft365-secure.com/verify/account?session=8347ab

---

### Header Analysis

SPF failed, meaning the sending IP is not authorized for the domain.

DKIM is not present, indicating no cryptographic validation.

Return-Path domain differs from legitimate Microsoft domains.

The sending IP resolves to a low-reputation hosting provider.

Conclusion: High suspicion of spoofed infrastructure.

---

### URL Analysis

Domain: login-microsoft365-secure.com  
Observation: Typosquatting and brand impersonation.

The domain contains:
- Brand name
- Hyphenated structure
- Recently registered domain (simulated lab check)

The path includes "verify/account", commonly used in credential harvesting kits.

The domain is not an official Microsoft domain.

---

### Content Analysis

Indicators of social engineering:

- Urgency ("immediately")
- Fear ("prevent suspension")
- Authority impersonation ("Microsoft Security")

The language is generic and not personalized.

---

### Verdict

Malicious – Credential Harvesting Phishing.

### MITRE ATT&CK Mapping

T1566 – Phishing  
T1566.002 – Spearphishing Link  

### Final SOC Action Taken

- Block domain at secure email gateway
- Add domain to proxy block list
- Check authentication logs for affected user
- Force password reset if link clicked
- Notify impacted user

---

## 4. Scenario 2 – Malicious Attachment (MalDoc)

### Email Overview

Sender: Accounts Payable <billing@trustedvendor-co.com>  
Subject: Invoice Payment Confirmation  
Attachment: Invoice_2026_Q1.docm  

Email context suggests overdue invoice.

---

### Static Analysis Observations

File type: .docm (macro-enabled Word document)

Metadata reveals:
- Author name mismatch
- Suspicious embedded macro code

Macro attempts to execute PowerShell command via:

    powershell -ExecutionPolicy Bypass -EncodedCommand

This is a strong indicator of malicious intent.

---

### Indicators of Compromise

- Suspicious PowerShell execution
- Encoded command usage
- External URL embedded inside macro

---

### Sandbox Behavior (Simulated)

Upon execution:

- Spawns PowerShell process
- Connects to suspicious external IP
- Downloads secondary payload
- Writes executable to temporary directory

Observed network connection to unknown external server over port 443.

---

### Verdict

Malicious – Macro-Based Loader.

---

### Containment Actions

- Isolate affected endpoint
- Block external IP at firewall
- Remove malicious email from all mailboxes
- Conduct EDR scan on impacted system
- Reset user credentials

---

## 5. Scenario 3 – Business Email Compromise (BEC)

### Email Overview

Sender Display Name: CEO – John Smith  
Actual Address: john.smith.ceo@gmail-support.com  
Subject: Urgent Vendor Payment  

Message requests urgent wire transfer for confidential acquisition.

---

### Analysis

Display name spoofing detected. The display name matches the CEO, but the domain is external.

Domain similarity analysis shows "gmail-support.com" is unrelated to corporate domain.

No malicious links or attachments present.

Behavioral red flags:

- Urgent financial request
- Request for secrecy
- Out-of-process communication

BEC often bypasses technical controls because there are no malicious payloads. It relies purely on social engineering.

---

### Final SOC Decision

Classified as BEC attempt.

Actions taken:

- Notify finance team
- Block sender domain
- Conduct user awareness reminder
- Monitor for similar impersonation attempts

---

## 6. Tools Used During Analysis

Header analyzers  
Used to interpret SPF, DKIM, and DMARC results clearly.

Threat intelligence platforms  
Used to check domain reputation, IP reputation, and file hashes.

Sandbox tools  
Used to observe runtime behavior of attachments and URLs in isolated environments.

Whois lookup tools  
Used to identify domain age and registration patterns.

URL decoding tools  
Used to analyze encoded query parameters or obfuscated links.

SIEM  
Used to correlate email alerts with authentication logs and endpoint telemetry.

Each tool supports a specific phase of investigation. None should be used in isolation.

---

## 7. Indicators of Compromise (IOC) Extraction Process

During analysis, I extract:

IP addresses  
Domains  
File hashes  
Sender email addresses  

These IOCs are:

- Added to block lists
- Searched across SIEM logs
- Used for proactive threat hunting

IOC extraction allows expansion from single incident response to broader environment validation.

---

## 8. Documentation & Reporting Process

A SOC report includes:

- Executive summary
- Technical findings
- Timeline of events
- Extracted IOCs
- Impact assessment
- Containment steps taken
- Recommendations

Severity classification is based on:

- User interaction
- Credential exposure
- Endpoint compromise
- Lateral movement potential

Escalation occurs when:

- Privileged accounts are involved
- Malware execution confirmed
- Financial fraud is attempted

Clear documentation ensures accountability and future reference.

---

## 9. Key Lessons Learned

Across all scenarios, patterns observed:

- Social engineering is consistent
- Identity compromise is primary objective
- Technical indicators change frequently
- Behavioral signals are more reliable than static indicators

Common attacker techniques include:

- Brand impersonation
- Domain typosquatting
- Macro-based payload delivery
- Urgency-based manipulation

To improve detection in the future:

- Strengthen correlation between email and authentication logs
- Monitor mailbox rule creation
- Enhance awareness training for high-risk departments

This workflow reflects my practical understanding of email threat analysis and demonstrates how I approach investigations methodically, evidence-based, and with defensive depth in mind.
