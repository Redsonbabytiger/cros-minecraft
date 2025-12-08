# Minecraft Files Automated Download/Setup Script
# Run this script to automatically download and setup all neccessary packages and files
# in order to play Minecraft on your chromebook.
echo "Would you like to download the crostini image file?"
echo "(You would have to take the image and restore it yourself first)"
echo "REMEMBER TO MOVE THE CROSTINI IMAGE FILE TO YOUR DOWNLOADS FOLDER!"
echo "DO NOT LEAVE IT IN YOUR LINUX FILES!"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1tOYQ74_ijmwMjFESw2EHJprlvDOmlMKo' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1tOYQ74_ijmwMjFESw2EHJprlvDOmlMKo" -O chromeos-linux-with-minecraft-old.tini && rm -rf /tmp/cookies.txt
fi
sudo apt update
echo -e "\e[36mRun a full upgrade of your apt packages before we start?\e[0m"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
  sudo apt full-upgrade -y
fi
echo -e "\e[36mInstall recomended cros packages?\e[0m"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
  sudo apt install cros-adapta cros-apt-config cros-garcon cros-guest-tools cros-host-fonts cros-im cros-logging cros-motd cros-notificationd cros-pipe-config cros-port-listener cros-pulse-config cros-sftp cros-sommelier cros-sommelier-config cros-sudo-config cros-systemd-overrides cros-tast-tests cros-ui-config cros-vmstat-metrics cros-wayland cros-xdg-desktop-portal -y
fi
echo -e "\e[36mInstall relevant keyring and other recomended packages?\e[0m"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
  sudo apt install nano neofetch pcmanfm htop debian-keyring debian-ports-archive-keyring python3-keyring -y
fi
echo "We are about to start the main part of the script."
echo "Which is to download the main zip file and unzip it for the files we need."
echo -e '\e[36mIf you already have downloaded the "Linux Backups" Folder, you can skip this step.\e[0m'
echo -e "\e[36mDownload the required Linux Backups Folder?\e[0m"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
echo -e "\e[36mDownloading the the main folder from google drive\e[0m"
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=19kZRFX1LHTnAHdUc78ZXQ62oKbe7rizg' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=19kZRFX1LHTnAHdUc78ZXQ62oKbe7rizg" -O LinuxBackups.zip && rm -rf /tmp/cookies.txt
echo -e "\e[36mUnziping the downloaded zip file\e[0m"
unzip LinuxBackups.zip
fi
cd 'Linux Backups'
echo -e "\e[36mRunning fabric installer for 1.21.10\e[0m"
echo -e "\e[36mYou will need to select 1.21.10 as your fabric version.\e[0m"
echo -e "\e[36m(The downloaded mods are for fabric 1.21.10)\e[0m"
java -jar fabric-installer.jar
echo -e "\e[36mNow time for the important part: replacing the 'saves' and 'mods' folders.\e[0m"
read -p 'Continue? y/n: '
if [[ "$action" == "y" ]]; then
  cd ~/.minecraft
  sudo rm -rf saves
  sudo rm -rf mods
  sudo cp -rt ~/.minecraft ~/'Linux Backups'/mods
  sudo cp -rt ~/.minecraft ~/'Linux Backups'/saves
fi
echo -e "\e[92mCrOS Minecraft Setup Complete!\e[0m"
