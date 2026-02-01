#!/bin/bash
set -euo pipefail
VERSION="1.1.0"
if [[ "$1" == "--version" ]]; then
    echo "cros-minecraft v$VERSION"
    exit 0
fi
# ===== COLOR CODES =====
CYAN="\e[36m"
YELLOW="\e[33m"
GREEN="\e[92m"
RESET="\e[0m"

# ===== FUNCTIONS =====

ask_yn () {
  local prompt="$1"
  local answer
  while true; do
    echo -ne "${CYAN}${prompt} (y/n): ${RESET}"
    read -r answer
    case "$answer" in
      y|Y) return 0 ;;
      n|N) return 1 ;;
      *) echo -e "${CYAN}Please enter y or n.${RESET}" ;;
    esac
  done
}

check_success () {
  if [[ $? -ne 0 ]]; then
    echo "❌ ERROR: $1 failed. Exiting."
    exit 1
  fi
}

download_gdrive () {
  # Arguments:
  # $1 = File ID or full URL
  # $2 = output filename
  local file_id="$1"
  local out="$2"

  echo -e "${YELLOW}[==== Downloading ${out} ====]${RESET}"
  gdown --fuzzy "$file_id" -O "$out"
  check_success "download of $out"

  if [[ ! -s "$out" ]]; then
    echo "❌ ERROR: $out downloaded but is empty or incomplete!"
    exit 1
  fi
}

# ===== INSTALL gdown USING pipx =====

echo -e "${YELLOW}[==== Installing pipx + python3-venv ====]${RESET}"
sudo apt update
sudo apt install -y pipx python3-venv
check_success "pipx install"

echo "Ensuring pipx path is active..."
pipx ensurepath

echo -e "${YELLOW}[==== Installing gdown ====]${RESET}"
pipx install gdown
check_success "gdown installation"

export PATH="$HOME/.local/bin:$PATH"
if ! command -v gdown >/dev/null 2>&1; then
  echo "❌ gdown installed but not found in PATH. Restart shell."
  exit 1
fi

# ===== SCRIPT START =====

echo "Minecraft Chromebook Setup Script"

# ---- Download crostini image ----
if ask_yn "Would you like to download the Crostini image file?"; then
  download_gdrive \
    "https://drive.google.com/file/d/1tOYQ74_ijmwMjFESw2EHJprlvDOmlMKo/view" \
    "chromeos-linux-with-minecraft-old.tini"
fi

# ---- APT update ----
echo "Updating apt..."
sudo apt update || { echo "apt update failed"; exit 1; }

if ask_yn "Run full upgrade first?"; then
  sudo apt full-upgrade -y || { echo "full-upgrade failed"; exit 1; }
fi

# ---- Cros packages ----
if ask_yn "Install recommended CrOS packages?"; then
  sudo apt install -y \
      cros-adapta cros-apt-config cros-garcon cros-guest-tools \
      cros-host-fonts cros-im cros-logging cros-motd cros-notificationd \
      cros-pipe-config cros-port-listener cros-pulse-config cros-sftp \
      cros-sommelier cros-sommelier-config cros-sudo-config \
      cros-systemd-overrides cros-tast-tests cros-ui-config \
      cros-vmstat-metrics cros-wayland cros-xdg-desktop-portal
  check_success "CrOS package install"
fi

# ---- Keyrings and utilities ----
if ask_yn "Install keyring + recommended utilities?"; then
  sudo apt install -y nano neofetch pcmanfm htop debian-keyring debian-ports-archive-keyring python3-keyring
  check_success "utility install"
fi

# ---- Download Linux Backups ----
echo "Preparing to download Linux Backups folder."
if ask_yn "Download Linux Backups zip from Google Drive?"; then
  download_gdrive \
    "https://drive.google.com/file/d/19kZRFX1LHTnAHdUc78ZXQ62oKbe7rizg/view" \
    "LinuxBackups.zip"

  echo -e "${YELLOW}[==== Unzipping LinuxBackups.zip ====]${RESET}"
  unzip -o LinuxBackups.zip || { echo "Unzip failed"; exit 1; }
fi

if [[ ! -d "Linux Backups" ]]; then
  echo "❌ ERROR: 'Linux Backups' folder not found. Cannot continue."
  exit 1
fi

cd "Linux Backups"

# ---- Fabric Installer ----
echo -e "${YELLOW}[==== Running Fabric Installer ====]${RESET}"
echo -e "${CYAN}Choose version 1.21.10 in the UI when prompted.${RESET}"

if [[ ! -f fabric-installer.jar ]]; then
  echo "❌ ERROR: fabric-installer.jar missing."
  exit 1
fi

java -jar fabric-installer.jar || { echo "Fabric installer failed"; exit 1; }

# ---- Replace Minecraft folders ----
echo -e "${CYAN}Ready to replace ~/.minecraft/{mods,saves}.${RESET}"

if ask_yn "Continue with replacing mods and saves?"; then

  MCDIR="$HOME/.minecraft"
  BACKUPDIR="$PWD"

  if [[ ! -d "$MCDIR" ]]; then
    echo "❌ ERROR: ~/.minecraft does not exist."
    exit 1
  fi

  cd "$MCDIR"

  echo -e "${YELLOW}[==== Removing old saves/mods ====]${RESET}"
  sudo rm -rf saves mods
  check_success "removal of saves and mods"

  echo -e "${YELLOW}[==== Copying new saves/mods ====]${RESET}"
  sudo cp -r "$BACKUPDIR/mods" "$MCDIR/"
  sudo cp -r "$BACKUPDIR/saves" "$MCDIR/"
  check_success "copy of saves/mods"
fi

echo -e "${GREEN}✔ CrOS Minecraft Setup Complete!${RESET}"
