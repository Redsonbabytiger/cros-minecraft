#!/bin/bash
# Minecraft Files Automated Download/Setup Script
# Run this script to automatically download and setup all necessary packages and files
# in order to play Minecraft on your Chromebook.
VERSION="3.0pre"
MC_INSTALLER_DATA="$HOME/cros-minecraft-packages"
if [[ "$1" == "--version" ]]; then
    echo "cros-minecraft v$VERSION"
    exit 0
fi
if [[ "$1" == "--help" ]]; then
    echo "To run cros-minecraft itself, the command is simple"
    echo "Use 'cros-minecraft' to run the script."
    echo "However, there are other subcommands you can use if you want to be fancy."
    echo "Use 'cros-minecraft-moderninstall' to install prism-launcher"
    echo "(Only exists in v3 of cros-minecraft)"
    echo "And finally, use 'cros-minecraft-legacyinstall' to install the normal minecraft launcher just like old times."
    echo "(In use by versions prior to v3)"
    echo "If you are running this script directly off of github, it may or may not actually have v3 features"
    echo "so only try them if you are sure that you installed v3."
    echo "You may check what version you are on using the --version flag when you use the command."
    exit 0
fi
if [[ "$1" == "--moderninstall" ]]; then
    echo "Running the prism launcher install script."
    cros-minecraft-moderninstall
    exit 0
fi
if [[ "$1" == "--vscode" ]]; then
    curl -LO "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo dpkg -i "code_1.108.2-1769004815_amd64.deb"
    exit 0
fi
if [[ "$1" == "--run" ]]; then
    echo "Launching Minecraft (PerfFabric Instance)"
    export QT_QPA_PLATFORM=xcb
    exec flatpak run org.prismlauncher.PrismLauncher "$@"
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
echo -e "\e[36mIf you choose to use the Modern Launcher, you will have the option to use the --run flag\e[0m"
echo -e "\e[36mWhich is basically one command to launch Minecraft using 'cros-minecraft --run'\e[0m"
echo -e "\e[36mChoice: Choose a installation option: \e[0m"
echo -e "\e[36m1) Install Minecraft with offical Minecraft Launcher (Requires you to press play with the launcher)\e[0m"
echo -e "\e[36m2) Install Minecraft with Modern Launcher (Prism Launcher)\e[0m"
read -p 'Choice: ' action
if [[ "$action" == "1" ]]; then
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
    MODERNINSTALL=false
fi
if [[ "$action" == "2" ]]; then
    echo -e "\e[36mContinuing with main script, will run Modern Installer when ready\e[0m"
    MODERNINSTALL=true
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
echo "Which is to download the main folder which contains the files we need."
echo -e '\e[36mIf you already have downloaded the folder, you can skip this step.\e[0m'
echo -e "\e[36mDownload the required Cros-Minecraft files?\e[0m"
read -p 'y/n: ' action
if [[ "$action" == "y" ]]; then
    echo -e "\e[36mDownloading the main folder from google drive\e[0m"
    # -----------------------------
    # Replaces wget Google Drive zip download
    # Zip File ID: 19kZRFX1LHTnAHdUc78ZXQ62oKbe7rizg
    # Folder ID: 1S0O37qCyuVO1Oka23sO4P5aryYSg0-Xv
    # -----------------------------
    gdown "1S0O37qCyuVO1Oka23sO4P5aryYSg0-Xv" --folder -O "$MC_INSTALLER_DATA"
fi
if [[ "$MODERNINSTALL" == true ]]; then
    echo "Running the prism launcher install script."
    cros-minecraft-moderninstall
    MANUAL_INSTALL=false
fi
# Here we check if the user did a manual install
if [[ "$MANUAL_INSTALL" == true ]]; then
    cros-minecraft-legacyinstall
fi
echo -e "\e[92mSuccess! You can now run the minecraft launcher!\e[0m"
echo -e "\e[36mBe sure to use the fabric version you installed for best performance as the script gives you performance mods.\e[0m"
echo -e "\e[36mIf you need a newer version of minecraft, please contact the developer on github.\e[0m"
echo -e "\e[92mCrOS Minecraft Setup Complete!\e[0m"
