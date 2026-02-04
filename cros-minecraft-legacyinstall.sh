MC_INSTALLER_DATA="$HOME/cros-minecraft-packages"
sudo dpkg -i "$MC_INSTALLER_DATA/libgdk-pixbuf2.0-0.deb"
# install minecraft package found in Linux Backups folder
echo -e "\e[36mInstalling Minecraft package from Linux Backups...\e[0m"
sudo dpkg -i "$MC_INSTALLER_DATA/Minecraft.deb"
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
if [[ -d "$MC_INSTALLER_DATA" ]]; then
    cd "$MC_INSTALLER_DATA"
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
        sudo cp -rt ~/.minecraft "$MC_INSTALLER_DATA/mods"
        sudo cp -rt ~/.minecraft "$MC_INSTALLER_DATA/saves"
    fi
    # Makes sure that the user owns the .minecraft folder so Minecraft can use the saves data
    sudo chown -R $USER:$USER ~/.minecraft
else
    echo -e "\e[91mError: Linux Backups folder not found. Please download it first.\e[0m"
    exit 1
