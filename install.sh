#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

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

# Function to install Docker on Ubuntu
install_docker_ubuntu() {
    echo "Installing to OS Version: $OS"
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
}

# Function to install Docker on Debian-based systems
install_docker_debian() {
    echo "Installing to OS Version: $OS"
    sudo apt-get update
    sudo apt-get install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
}

# Function to install Docker on Fedora
install_docker_fedora() {
    echo "Installing to OS Version: $OS"  
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
}

# Install Docker based on OS
case "$OS" in
    ubuntu)
        install_docker_ubuntu
        ;;
    debian)
        install_docker_debian
        ;;
    fedora)
        install_docker_fedora
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

# Add the current user to the Docker group
sudo groupadd docker || true
sudo usermod -aG docker $USER

# Plex setup
PLEX_DIR=~/Downloads/plex
mkdir -p "$PLEX_DIR/database" "$PLEX_DIR/transcode" "$PLEX_DIR/media"

# Copy Docker Compose configuration for Plex
cp ./plex/docker-compose.yml "$PLEX_DIR"

# Navigate to Plex directory and start services
cd "$PLEX_DIR"
docker-compose up -d

# Check running containers
docker ps

# Ensure configuration directory exists
mkdir -p ./config

# Ensure the Downloads directory exists for the user
DOWNLOADS_DIR="${HOME}/Downloads"
if [ ! -d "$DOWNLOADS_DIR" ]; then
    mkdir -p "$DOWNLOADS_DIR"
    echo "Created Downloads directory at $DOWNLOADS_DIR"
fi

# qBittorrent setup
QBITTORRENT_DIR=/opt/qbittorrent
sudo mkdir -p "$QBITTORRENT_DIR"

# Copy qBittorrent files
sudo cp qbittorrent "$QBITTORRENT_DIR"

# Navigate to qBittorrent directory and start services
cd "$QBITTORRENT_DIR"
docker-compose up -d

# Return to the initial directory
cd "$INITIAL_DIR"
