#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
# set -e

# Save the current directory
INITIAL_DIR=$(pwd)

# Detect the operating system
if [ -f /etc/os-release ]; then
    source /etc/os-release
    OS=$ID
else
    echo "Unsupported operating system. Exiting."
    exit 1
fi

# Function to uninstall Docker on Ubuntu
uninstall_docker_ubuntu() {
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    sudo apt-get autoremove -y --purge
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo rm -rf /etc/apt/keyrings/docker.asc /etc/apt/sources.list.d/docker.list
}

# Function to uninstall Docker on Debian-based systems
uninstall_docker_debian() {
    sudo dnf remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo rm -rf /var/lib/docker
    sudo rm -f /etc/yum.repos.d/docker-ce.repo
}

# Function to uninstall Docker on Fedora
uninstall_docker_fedora() {
    sudo dnf remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo rm -rf /var/lib/docker
    sudo rm -f /etc/yum.repos.d/docker-ce.repo
}

# Uninstall Docker based on OS
case "$OS" in
    ubuntu)
        uninstall_docker_ubuntu
        ;;
    debian)
        uninstall_docker_debian
        ;;
    fedora)
        uninstall_docker_fedora
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

# Remove Docker group
sudo groupdel docker || true

# Remove Plex setup
PLEX_DIR=~/Downloads/plex
if [ -d "$PLEX_DIR" ]; then
    sudo rm -rf "$PLEX_DIR"
    echo "Removed Plex directory: $PLEX_DIR"
fi

# Remove qBittorrent setup
QBITTORRENT_DIR=/opt/qbittorrent
if [ -d "$QBITTORRENT_DIR" ]; then
    sudo rm -rf "$QBITTORRENT_DIR"
    echo "Removed qBittorrent directory: $QBITTORRENT_DIR"
fi

# Return to the initial directory
cd "$INITIAL_DIR"
echo "Cleanup complete. Returned to $INITIAL_DIR"
