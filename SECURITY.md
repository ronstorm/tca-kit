# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security bugs seriously. We appreciate your efforts to responsibly disclose your findings, and will make every effort to acknowledge your contributions.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to [me@amitsen.de](mailto:me@amitsen.de).

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

### What to Include

Please include the following information in your report:

- Type of issue (e.g. buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### What to Expect

After you submit a report, we will:

1. Confirm receipt of your vulnerability report within 48 hours
2. Provide regular updates on our progress
3. Credit you in our security advisories (unless you prefer to remain anonymous)

### Security Advisories

Security advisories will be published on our [GitHub Security Advisories](https://github.com/ronstorm/tca-kit/security/advisories) page.

## Security Best Practices

When using TCAKit in your applications, please follow these security best practices:

### Dependency Management
- Keep TCAKit updated to the latest version
- Regularly audit your dependencies for known vulnerabilities
- Use dependency scanning tools in your CI/CD pipeline

### State Management
- Never store sensitive data (passwords, tokens, etc.) in your app state
- Use secure storage solutions for sensitive data
- Implement proper data validation in your reducers

### Effect Security
- Validate all inputs in async effects
- Use secure network communication (HTTPS)
- Implement proper error handling to avoid information leakage

### Testing
- Include security testing in your test suite
- Test with malicious inputs
- Verify that sensitive data is not logged or exposed

## Security Considerations

TCAKit is designed with security in mind:

- **No external dependencies**: Reduces attack surface
- **Pure functions**: Reducers are side-effect free and predictable
- **Type safety**: Swift's type system helps prevent many common vulnerabilities
- **MainActor isolation**: UI updates are properly isolated to the main thread

## Contact

For security-related questions or concerns, please contact us at [me@amitsen.de](mailto:me@amitsen.de).

## Acknowledgments

We would like to thank the following security researchers who have helped improve TCAKit's security:

- [Your name will be added here when you report a vulnerability]

Thank you for helping keep TCAKit and our users safe!
