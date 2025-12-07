# Minecraft Files Automated Download/Setup Script
# Run this script to automatically download and setup all neccessary packages and files
# in order to play Minecraft on your chromebook.
echo "Would you like to download the crostini image file?"
echo "(You would have to take the image and restore it yourself first)"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
  curl -L https://url.mvhs.io/restorefile
fi
sudo apt update
echo "Run a full upgrade of your package before we start?"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
  sudo apt full-upgrade -y
fi
echo "Install recomended cros packages?"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
  sudo apt install cros-adapta cros-apt-config cros-garcon cros-guest-tools cros-host-fonts cros-im cros-logging cros-motd cros-notificationd cros-pipe-config cros-port-listener cros-pulse-config cros-sftp cros-sommelier cros-sommelier-config cros-sudo-config cros-systemd-overrides cros-tast-tests cros-ui-config cros-vmstat-metrics cros-wayland cros-xdg-desktop-portal -y
fi
echo "Install relevant keyring and other recomended packages?"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
  sudo apt install nano neofetch pcmanfm htop debian-keyring debian-ports-archive-keyring python3-keyring -y
fi
echo -e "\e[36mWe are about to start the main part of the script.\e[0m"
echo -e "\e[36mWhich is to download the main zip file and unzip it for the files we need.\e[0m"
echo -e "\e[36mWould you like to continue?\e[0m"
read -p 'y/n: ' action
if [[ "$action" != "y" ]]; then
  exit
fi
echo -e "\e[36mDownloading the the main folder from google drive\e[0m"
curl -L https://url.mvhs.io/minecraftfiles
echo -e "\e[36mUnziping the downloaded zip file\e[0m"

echo "**Insert the unziping code here**"

cd 'Linux Backups'

echo "Run fabric installer for 1.21.10?"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
  java -jar fabric-installer.jar
fi
