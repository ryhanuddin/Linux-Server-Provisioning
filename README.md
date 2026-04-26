# Linux Server Provisioning

This repository contains a Bash-based Linux server provisioning script for Ubuntu/Debian lab environments. The script automates common system administration tasks that are usually performed after creating a fresh Linux VM.

It demonstrates practical sysadmin work such as remote access setup, user management, firewall configuration, SSH hardening, patch management, swap configuration, audit logging, and basic reporting.

## What the Script Does

The main script is located at:

```text
scripts/provision-linux-server.sh
```

It performs the following tasks:

- Updates the package index
- Installs common administration tools such as `curl`, `wget`, `vim`, `git`, `ufw`, `htop`, and `fail2ban`
- Installs and enables OpenSSH Server for terminal-based remote access
- Installs and enables XRDP for remote desktop access
- Creates a sudo-enabled lab admin user
- Sets default lab credentials for easier testing
- Configures UFW firewall rules for SSH and XRDP
- Backs up the SSH server configuration file
- Disables direct root SSH login
- Enables SSH public key authentication
- Enables fail2ban for basic brute-force protection
- Enables automatic security updates
- Creates a persistent 1 GB swap file
- Installs and enables audit logging
- Generates a basic provisioning report

## Default Lab Credentials

```text
Username: sysadmin
Password: sysadmin
```

These credentials are for local VM lab testing only. Change the password before using this script in any real or shared environment.

## Why This Project Matters

System administrators often need to prepare new Linux servers consistently and quickly. Instead of manually installing services, creating users, configuring firewalls, and checking system status, this script automates those tasks in a repeatable way.

This project shows:

- Bash scripting
- Linux server administration
- Service installation and management
- SSH and XRDP remote access setup
- User and sudo group management
- UFW firewall configuration
- Basic Linux hardening
- Patch management using unattended upgrades
- Swap configuration for low-memory VMs
- Audit logging and login monitoring
- System reporting

## Usage

Clone the repository:

```bash
git clone https://github.com/ryhanuddin/Linux-Server-Provisioning.git
cd Linux-Server-Provisioning
```

Run the script:

```bash
sudo bash scripts/provision-linux-server.sh
```

The report will be saved at:

```text
/var/log/server-provisioning-report.txt
```

To view the report:

```bash
sudo cat /var/log/server-provisioning-report.txt
```

## Repository Structure

```text
Linux-Server-Provisioning
├── README.md
├── scripts
│   └── provision-linux-server.sh
├── docs
│   └── security-notes.md
├── sample-output
│   └── server-provisioning-report.txt
└── .gitignore
```

## Notes

This script is mainly intended for Ubuntu/Debian-based lab VMs. Review the username, password, firewall ports, SSH settings, and XRDP usage before adapting it for production.

For a production server, avoid hardcoded passwords and consider using SSH keys, centralized logging, stronger firewall rules, and configuration management tools such as Ansible.
