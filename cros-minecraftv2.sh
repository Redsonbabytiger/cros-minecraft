#!/bin/bash
# Minecraft Files Automated Download/Setup Script
# Run this script to automatically download and setup all necessary packages and files
# in order to play Minecraft on your Chromebook.
VERSION="2.0.0"
if [[ "$1" == "--version" ]]; then
    echo "cros-minecraft v$VERSION"
    exit 0
fi
# --- Ensure pipx + gdown installed FIRST ---
echo -e "\e[36mInstalling pipx and gdown (required for downloads)...\e[0m"
sudo apt update
sudo apt install -y pipx python3-venv
pipx ensurepath
pipx install gdown

# Ensure shell sees pipx-installed tools
export PATH="$PATH:$HOME/.local/bin"

echo "Would you like to download the crostini image file?"
echo "(You would have to take the image and restore it yourself first)"
echo "REMEMBER TO MOVE THE CROSTINI IMAGE FILE TO YOUR DOWNLOADS FOLDER!"
echo "DO NOT LEAVE IT IN YOUR LINUX FILES!"
echo -e "\e[36mChoice: Do you want to download the 2GB Crostini image file or\e[0m"
echo -e "\e[36mWould you like to manually install the necessary packages?\e[0m"
echo -e "\e[36m1) Download Crostini image file\e[0m"
echo -e "\e[36m2) Manually install packages\e[0m"
read -p 'Choice: ' action
if [[ "$action" == "1" ]]; then
    # -----------------------------
    # Replaces wget Google Drive hack
    # ID: 1tOYQ74_ijmwMjFESw2EHJprlvDOmlMKo
    # -----------------------------
    gdown "1tOYQ74_ijmwMjFESw2EHJprlvDOmlMKo" -O chromeos-linux-with-minecraft-old.tini
fi
if [[ "$action" == "2" ]]; then
    #Insert manual package installation steps
    echo -e "\e[36mStarting manual package installation...\e[0m"
    sudo apt install unzip openjdk-17-jre libopengl0 -y
    sudo apt install libpulse0 libpulse-dev mesa-utils pciutils -y
    sudo apt install gnome-keyring-pkcs11 gnome-keyring debian-keyring debian-ports-archive-keyring -y
    # Ensure java can run properly from home directory
    echo 'export PATH=$PATH:/usr/lib/jvm/java-17-openjdk-amd64/bin' >> ~/.bashrc
    source ~/.bashrc
    # Create variable to remind the script that the user chose manual install
    MANUAL_INSTALL=true
fi

# Update and upgrade apt packages
sudo apt update
echo -e "\e[36mRun a full upgrade of your apt packages before we start?\e[0m"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
    sudo apt full-upgrade -y
fi

echo -e "\e[36mInstall recommended cros packages?\e[0m"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
    sudo apt install cros-adapta cros-apt-config cros-garcon cros-guest-tools cros-host-fonts cros-im cros-logging cros-motd cros-notificationd cros-pipe-config cros-port-listener cros-pulse-config cros-sftp cros-sommelier cros-sommelier-config cros-sudo-config cros-systemd-overrides cros-ui-config cros-vmstat-metrics cros-wayland cros-xdg-desktop-portal -y
fi

echo -e "\e[36mInstall relevant keyring and other recommended packages?\e[0m"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
    sudo apt install nano neofetch pcmanfm htop debian-keyring debian-ports-archive-keyring python3-keyring pipx python3-venv -y
    pipx ensurepath
fi

echo "We are about to start the main part of the script."
echo "Which is to download the main zip file and unzip it for the files we need."
echo -e '\e[36mIf you already have downloaded the "Linux Backups" Folder, you can skip this step.\e[0m'
echo -e "\e[36mDownload the required Linux Backups Folder?\e[0m"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
    echo -e "\e[36mDownloading the main folder from google drive\e[0m"
    # -----------------------------
    # Replaces wget Google Drive zip download
    # ID: 19kZRFX1LHTnAHdUc78ZXQ62oKbe7rizg
    # -----------------------------
    gdown "19kZRFX1LHTnAHdUc78ZXQ62oKbe7rizg" -O LinuxBackups.zip
    echo -e "\e[36mUnzipping the downloaded zip file\e[0m"
    unzip LinuxBackups.zip
fi

# Here we check if the user did a manual install
if [[ "$MANUAL_INSTALL" == true ]]; then
    # install minecraft package found in Linux Backups folder
    echo -e "\e[36mInstalling Minecraft package from Linux Backups...\e[0m"
    sudo dpkg -i "$HOME/Linux Backups/Minecraft.deb"
    # fix any missing dependencies
    sudo apt --fix-broken install -y
    # Check if minecraft installed correctly
    if command -v minecraft-launcher &> /dev/null; then
        echo -e "\e[92mMinecraft installed successfully!\e[0m"
    else
        echo -e "\e[91mMinecraft installation failed. Please check for errors.\e[0m"
        exit 1
    fi
    # look for any openGL drivers/packages/libraries that may be missing
    echo -e "\e[36mChecking for missing OpenGL libraries...\e[0m"
    # Check and install missing OpenGL libraries
    for package in libgl1-mesa-glx libgl1-mesa-dri libpulse0 libpulse-dev gnome-keyring-pkcs11 gnome-keyring libopengl0; do
      if ! dpkg -l | grep -q "$package"; then
        echo -e "\e[36mInstalling missing package: $package\e[0m"
        sudo apt install "$package" -y
      else
        echo -e "\e[92mPackage $package is already installed.\e[0m"
      fi
    done
    # Run the minecraft launcher once to create necessary folders
    echo "Running Minecraft Launcher to create necessary folders..."
    echo -e "\e[36mBe sure to close the Minecraft Launcher once you're signed-in\e[0m"
    echo -e "\e[36mDon't start playing minecraft since the script is not finished\e[0m"
    minecraft-launcher &
    # Wait for the launcher to close before proceeding
    wait $!
    echo -e "\e[92mMinecraft Launcher closed. Proceeding with setup...\e[0m"

    echo -e "\e[36mSetting up Fabric and copying saves/mods...\e[0m"

    # Check if Linux Backups folder exists before proceeding
    if [[ -d "$HOME/Linux Backups" ]]; then
        cd "$HOME/Linux Backups"
        echo -e "\e[36mRunning fabric installer for 1.21.10\e[0m"
        echo -e "\e[36mYou will need to select 1.21.10 as your fabric version.\e[0m"
        echo -e "\e[36m(The downloaded mods are for fabric 1.21.10)\e[0m"
        java -jar fabric-installer.jar

        echo -e "\e[36mNow time for the important part: replacing the 'saves' and 'mods' folders.\e[0m"
        read -p 'Continue? y/n: ' action
        if [[ "$action" == "y" ]]; then
            cd ~/.minecraft
            sudo rm -rf saves
            sudo rm -rf mods
            sudo cp -rt ~/.minecraft "$HOME/Linux Backups/mods"
            sudo cp -rt ~/.minecraft "$HOME/Linux Backups/saves"
        fi
        # Makes sure that the user owns the .minecraft folder so Minecraft can use the saves data
        sudo chown -R $USER:$USER ~/.minecraft
    else
        echo -e "\e[91mError: Linux Backups folder not found. Please download it first.\e[0m"
        exit 1
    fi
fi
echo -e "\e[92mSuccess! You can now run the minecraft launcher!\e[0m"
echo -e "\e[36mBe sure to use the fabric version you installed for best performance as the script gives you performance mods.\e[0m"
echo -e "\e[36mIf you need a newer version of minecraft, please contact the developer on github.\e[0m"
echo -e "\e[92mCrOS Minecraft Setup Complete!\e[0m"
