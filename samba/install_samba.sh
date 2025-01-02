sudo apt update
sudo apt upgrade -y

sudo apt install samba samba-common-bin -y

sudo smbpasswd -a <USERNAME>

sudo systemctl restart smbd