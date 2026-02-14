# Putting It All Together  
**TryHackMe – How The Web Works**

## Introduction

Learning web concepts one by one can feel manageable, but also fragmented. DNS explains names, HTTP explains messages, browsers explain rendering, servers explain logic. On their own, each topic makes sense. The real understanding comes from seeing how they connect.

Putting everything together matters because web security problems rarely live in a single layer. Vulnerabilities emerge when data moves between layers and assumptions break along the way. This is the point where theory starts turning into security thinking.

This room helped shift my view from isolated concepts to a continuous system, where every step influences the next.

---

## End-to-End Web Request Flow

Everything starts when a URL is entered into the browser. That single action triggers a chain of events across multiple systems.

The browser first needs to know where to connect, so DNS resolution translates the domain name into an IP address. This step decides which server will receive the request.

Once the destination is known, a network connection is established. TCP provides reliable transport, while TLS may wrap the connection to protect confidentiality and integrity. These layers exist before any web-specific logic begins.

On top of that connection, the browser sends an HTTP request. The server processes it and returns an HTTP response. The browser then interprets that response and renders the result. What feels instant to the user is actually a layered conversation.

---

## Browser, Network, and Server Roles

The browser is responsible for initiating requests, displaying responses, executing client-side code, and managing local state like cookies. It is fully controlled by the user, even if the interface tries to restrict behavior.

The network is responsible for moving data between systems. It does not understand applications, only packets and connections. From a security perspective, the network is untrusted and observable.

The server receives requests and makes decisions. It runs application logic, enforces access rules, and interacts with databases or other services. This is where security controls must exist.

Trust boundaries appear wherever responsibility changes. The most important boundary is between browser and server, but others exist between application layers and external services.

---

## Front-End and Back-End Interaction

User interaction begins on the front end. Input entered into forms or triggered by buttons is packaged into HTTP requests and sent to the server.

The back end processes this input, applies business logic, and determines what should happen next. The result is sent back as data or content, which the browser then displays.

Client-side controls can guide users, but they cannot enforce security. Any logic that runs in the browser can be changed or bypassed. Security only exists where the server verifies and enforces rules independently.

Seeing this interaction as a data path instead of a visual interface changes how security issues are recognized.

---

## State, Sessions, and User Identity

HTTP does not remember previous requests. Each request arrives at the server without context unless something is added.

Cookies and sessions provide that missing context. A small identifier stored in the browser allows the server to link multiple requests to the same user state.

Authentication depends entirely on this mechanism. If session handling is weak, identity breaks down. Many serious vulnerabilities target this glue layer because it connects otherwise independent requests into a meaningful whole.

Understanding state explains why login systems are fragile and why small mistakes can have large consequences.

---

## How Real Applications Are Structured

Web applications are not just collections of pages. Pages are often only views into deeper functionality.

Behind visible pages are endpoints, parameters, and logic paths that users never directly see. Some features exist only for certain roles, environments, or conditions.

Hidden logic is not necessarily secret logic. If it is reachable through a request, it exists as part of the application’s surface. Security testing depends on recognizing that applications are defined by behavior, not menus.

---

## Where Vulnerabilities Are Born

Vulnerabilities usually appear where user-controlled data crosses a trust boundary. Each transition is a chance for assumptions to fail.

Misunderstandings between client and server are common sources of issues. Developers may assume the client behaves honestly. Attackers do not.

Many vulnerabilities come from reasonable assumptions made in isolation that become unsafe when combined. The system works as designed, but not as expected under hostile input.

---

## Common Beginner Gaps

It is possible to know definitions without understanding flow. Memorizing terms does not guarantee insight.

Another gap is focusing on pages instead of data paths. Pages are just representations of underlying processes.

Tools can also create false confidence. Without understanding architecture, tool output becomes noise rather than knowledge.

This room emphasized that understanding precedes effective testing.

---

## Security Mindset Takeaways

Web security requires thinking in systems, not features. Each component makes sense alone, but security lives in their interaction.

Mapping how data flows through the system is more valuable than memorizing vulnerabilities. Once the flow is clear, weaknesses become easier to predict.

Most web vulnerabilities are not magic bugs. They are logic failures created by complexity, assumptions, and misplaced trust.

---

## Summary

Putting all web concepts together transforms scattered knowledge into a coherent mental model. The web becomes a sequence of connected steps, each with its own role and risk.

This unified understanding prepares the learner to move forward into web enumeration, vulnerability discovery, and practical web hacking. When the system is understood end-to-end, security testing becomes intentional rather than accidental.
