#!/bin/bash

# Initial setup for a new VM deployed from an OVA

# Update the system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages (nano, curl, git, zip, unzip, ufw, htop)
echo "Installing essential packages..."
sudo apt install -y curl git nano zip unzip ufw htop

# Set up UFW (Uncomplicated Firewall)
echo "Configuring firewall with UFW..."
sudo ufw allow OpenSSH
sudo ufw enable
echo "Firewall status:"
sudo ufw status

# Change hostname (device name)
read -p "Enter the new hostname (device name): " new_hostname
echo "Changing hostname to $new_hostname..."
sudo hostnamectl set-hostname $new_hostname

# Update /etc/hosts file
echo "Updating /etc/hosts file with new hostname..."
sudo sed -i "s/127.0.1.1 .*/127.0.1.1 $new_hostname/" /etc/hosts
echo "Hostname changed and /etc/hosts updated."

# Configure IP address and subnet mask
read -p "Enter the IP address: " ip_address
read -p "Enter the subnet mask: " subnet_mask
echo "Configuring network with IP address: $ip_address and subnet mask: $subnet_mask"

# Update the network configuration file (assuming the network interface is `eth0`)
sudo bash -c "cat > /etc/netplan/01-netcfg.yaml" <<EOL
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - $ip_address/$subnet_mask
      gateway4: <Insert_Gateway_IP>
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOL

# Apply the network configuration
sudo netplan apply
echo "Network configuration applied."

# Create a new user (if needed)
read -p "Do you want to create a new user? (y/n): " create_user
if [ "$create_user" == "y" ]; then
    read -p "Enter new username: " username
    sudo adduser $username
    sudo usermod -aG sudo $username
    echo "User $username created and added to sudo group."
fi

# Set timezone (optional)
read -p "Do you want to set the timezone? (y/n): " set_timezone
if [ "$set_timezone" == "y" ]; then
    sudo dpkg-reconfigure tzdata
fi

# Clean up unnecessary packages
echo "Cleaning up unnecessary packages..."
sudo apt autoremove -y
sudo apt autoclean -y

# Clear bash history permanently (clears memory and file)
echo "Clearing bash history..."
cat /dev/null > ~/.bash_history
history -c
echo "Command history cleared."

# Check disk space and system status
echo "Disk space usage:"
df -h
echo "Uptime:"
uptime

# Reboot the system (optional)
read -p "Do you want to reboot the system? (y/n): " reboot_now
if [ "$reboot_now" == "y" ]; then
    echo "Rebooting..."
    sudo reboot
else
    echo "Setup complete! Please review the changes and reboot if necessary."
fi
