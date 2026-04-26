#!/bin/bash

# Linux server provisioning for Ubuntu/Debian lab VMs.
# Sets up remote access, basic security, swap, audit logging, and reporting.

set -e

ADMIN_USER="sysadmin"
SSH_PORT="22"
XRDP_PORT="3389"
SWAP_SIZE="1G"
REPORT_FILE="/var/log/server-provisioning-report.txt"

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

echo "[+] Updating package index..."
apt update -y

echo "[+] Installing admin tools..."
apt install -y curl wget vim git net-tools ufw htop unzip fail2ban

echo "[+] Installing and enabling SSH..."
apt install -y openssh-server
systemctl enable --now ssh

echo "[+] Installing and enabling XRDP..."
apt install -y xrdp
systemctl enable --now xrdp

echo "[+] Creating admin user if missing..."
if id "$ADMIN_USER" >/dev/null 2>&1; then
    echo "[=] User $ADMIN_USER already exists."
else
    adduser --disabled-password --gecos "" "$ADMIN_USER"
    echo "$ADMIN_USER:$ADMIN_USER" | chpasswd
    usermod -aG sudo "$ADMIN_USER"
    echo "[+] User $ADMIN_USER created with sudo access."
    echo "[!] Lab password set as: $ADMIN_USER"
fi

echo "[+] Configuring firewall..."
ufw allow "$SSH_PORT"/tcp
ufw allow "$XRDP_PORT"/tcp
ufw --force enable

echo "[+] Backing up SSH configuration..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

echo "[+] Applying basic SSH hardening..."
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

echo "[+] Restarting SSH..."
systemctl restart ssh || systemctl restart sshd

echo "[+] Enabling fail2ban..."
systemctl enable fail2ban
systemctl restart fail2ban

echo "[+] Enabling automatic security updates..."
apt install -y unattended-upgrades apt-listchanges
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "[+] Creating swap file if missing..."
if [ -f /swapfile ]; then
    echo "[=] Swap file already exists."
else
    fallocate -l "$SWAP_SIZE" /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    if ! grep -q "/swapfile" /etc/fstab; then
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
    fi

    echo "[+] Swap file created: $SWAP_SIZE"
fi

echo "[+] Installing and enabling audit logging..."
apt install -y auditd audispd-plugins
systemctl enable --now auditd

echo "[+] Checking service status..."
systemctl is-active --quiet ssh && echo "[+] SSH is running." || echo "[!] SSH is not running."
systemctl is-active --quiet xrdp && echo "[+] XRDP is running." || echo "[!] XRDP is not running."
systemctl is-active --quiet fail2ban && echo "[+] fail2ban is running." || echo "[!] fail2ban is not running."
systemctl is-active --quiet auditd && echo "[+] auditd is running." || echo "[!] auditd is not running."

echo "[+] Creating system report..."
{
  echo "Linux Server Provisioning Report"
  echo "Generated: $(date)"
  echo "Hostname: $(hostname)"
  echo "Kernel: $(uname -r)"
  echo "Admin User: $ADMIN_USER"
  echo "Default Lab Password: $ADMIN_USER"
  echo

  echo "Service Status:"
  echo "SSH: $(systemctl is-active ssh)"
  echo "XRDP: $(systemctl is-active xrdp)"
  echo "fail2ban: $(systemctl is-active fail2ban)"
  echo "auditd: $(systemctl is-active auditd)"
  echo

  echo "Firewall Status:"
  ufw status
  echo

  echo "Swap Status:"
  swapon --show
  echo

  echo "Disk Usage:"
  df -h
  echo

  echo "Memory:"
  free -h
  echo

  echo "Recent Login Activity:"
  last -a | head -10
  echo

  echo "User Login Summary:"
  lastlog | head -10
  echo

  echo "Recent SSH Logs:"
  journalctl -u ssh --no-pager -n 20
  echo

  echo "Automatic Security Updates:"
  systemctl is-enabled unattended-upgrades 2>/dev/null || echo "unattended-upgrades status unavailable"

} > "$REPORT_FILE"

echo "[+] Provisioning complete."
echo "[+] Report saved to $REPORT_FILE"
