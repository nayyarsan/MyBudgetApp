# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | Yes       |

## Reporting a Vulnerability

If you discover a security vulnerability, please **do not** open a public GitHub issue.

Instead, email the details to the repository owner directly via GitHub's private messaging, or open a [GitHub Security Advisory](https://github.com/nayyarsan/MyBudgetApp/security/advisories/new).

Please include:
- A description of the vulnerability
- Steps to reproduce
- Potential impact

You can expect a response within **72 hours**. If the vulnerability is confirmed, a fix will be prioritised and a patched release issued. You will be credited in the release notes unless you prefer to remain anonymous.

## Scope

This app stores sensitive financial data locally on-device (SQLite via Drift) and optionally syncs to Firebase Firestore. Areas of particular concern:

- Local database access / encryption
- Firebase authentication and Firestore security rules
- Biometric authentication bypass
- Insecure storage of credentials or tokens
