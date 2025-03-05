# Security Policy

## Supported Versions  

We provide security updates for the following versions of our **Point of Sale (POS) System**:

| Version | Supported          |
| ------- | ------------------ |
| 5.1.x   | :white_check_mark: |
| 5.0.x   | :x:                |
| 4.0.x   | :white_check_mark: |
| < 4.0   | :x:                |

- **Active Security Support**: Security patches and updates are actively provided.  
- **Limited Security Support**: Only critical vulnerabilities are patched.  
- **No Support**: Versions below 5.0.x are no longer maintained.  

It is recommended to upgrade to the latest version to receive the most recent security updates.

---

## Reporting a Vulnerability  

### How to Report  

If you discover a security vulnerability, report it responsibly to avoid public disclosure before a fix is available.  

1. **Email studentsdav6@gmail.com** with details of the vulnerability.  
2. **Do not disclose the issue publicly** in GitHub issues or discussions.  
3. Expect an acknowledgment within **48 hours** and updates throughout the resolution process.  
4. Security patches will be released in the **next stable version** after verification.  
5. Contributors who report valid security issues may receive credit in our **Security Hall of Fame** if desired.  

For any security concerns, contact us at **studentsdav6@gmail.com**.

---

## Security Best Practices  

We follow industry best practices to maintain the security of this POS system.

### Authentication and Access Control  
- Multi-factor authentication (MFA) support.  
- Role-based access control (RBAC) for user permissions.  
- Enforced strong password policies.  

### Data Protection  
- End-to-end encryption (E2EE) for sensitive data.  
- Secure API communication using HTTPS/TLS.  
- Regular database backups and disaster recovery mechanisms.  

### Code Security  
- Static code analysis to detect vulnerabilities.  
- Regular security audits and penetration testing.  
- Secure dependency management and updates.  

### Payment and Transaction Security  
- Compliance with PCI-DSS for payment processing.  
- Protection against SQL Injection and XSS attacks.  
- Logging and monitoring of suspicious payment activities.  

---

## Security Updates and Patch Policy  

- **Critical patches** are released immediately after issue verification.  
- **Regular security updates** are included in minor and major releases.  
- **Older versions (below 4.0.x)** no longer receive security patches.  

Users should regularly check for updates and apply patches to maintain security.

---

## How You Can Contribute  

We encourage developers, security researchers, and contributors to help improve the security of this project.

Ways to contribute:  
- Review source code and report security issues.  
- Follow secure coding practices when submitting pull requests.  
- Help document security best practices and compliance guidelines.  

If you have a security-related contribution, submit it through a **GitHub security advisory** or contact our team.

---

## License and Compliance  

This project is licensed under **GNU General Public License v2.0 (GPL-2.0)**.  
All contributions, including security patches, must adhere to open-source principles.  

For regulatory compliance, we follow industry security standards, including:  
- **General Data Protection Regulation (GDPR)**  
- **Payment Card Industry Data Security Standard (PCI-DSS)**  
- **ISO 27001 Security Guidelines**  

Organizations using this software should ensure compliance with applicable laws and regulations.
