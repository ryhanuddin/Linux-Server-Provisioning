# Security Notes

This project is intended for lab use. It includes some basic hardening steps but should not be treated as a complete production security baseline.

## Included Security Improvements

- Direct root SSH login is disabled.
- SSH public key authentication is enabled.
- UFW firewall is enabled.
- SSH and XRDP ports are explicitly allowed.
- fail2ban is enabled for basic brute-force protection.
- Automatic security updates are enabled.
- auditd is enabled for audit logging.

## Lab Credential Warning

The script creates a lab user with the following default credentials:

```text
Username: sysadmin
Password: sysadmin
```

This is useful for local VM testing, especially with XRDP. Do not use this default password in production.

## Recommended Production Changes

- Replace the default password immediately.
- Use SSH keys instead of passwords.
- Restrict SSH access to trusted IP addresses.
- Avoid exposing XRDP directly to the internet.
- Forward logs to a central logging or SIEM platform.
- Review sudo access regularly.
