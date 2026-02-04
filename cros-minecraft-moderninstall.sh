#!/bin/bash
set -e

# ---- Dependencies ----
sudo apt install -y flatpak libgl-image-display0 libgle3
flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ---- Force X11 (prevents Wayland crashes on Crostini) ----
export QT_QPA_PLATFORM=xcb

# ---- Install Prism Launcher ----
flatpak install -y flathub org.prismlauncher.PrismLauncher

# ---- Paths ----
PRISM_DIR="$HOME/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher"
INSTANCES_DIR="$PRISM_DIR/instances"
INSTANCE_NAME="PerfFabric"
INSTANCE_DIR="$INSTANCES_DIR/$INSTANCE_NAME"
MC_DIR="$INSTANCE_DIR/minecraft"
MC_INSTALLER_DATA="$HOME/cros-minecraft-packages"

# ---- Download mod pack data ----
if [ ! -d "$MC_INSTALLER_DATA" ]; then
  echo "Cros-Minecraft Installer Data folder not found, downloading it..."
  gdown "1S0O37qCyuVO1Oka23sO4P5aryYSg0-Xv" --folder -O "$MC_INSTALLER_DATA"
fi

# ---- Create instance structure (ONLY if missing) ----
if [ ! -d "$INSTANCE_DIR" ]; then
  mkdir -p "$MC_DIR/mods"

  # instance.cfg
  cat > "$INSTANCE_DIR/instance.cfg" <<EOF
InstanceType=OneSix
name=$INSTANCE_NAME
icon=default
EOF

  # mmc-pack.json (Fabric)
  cat > "$INSTANCE_DIR/mmc-pack.json" <<EOF
{
  "formatVersion": 1,
  "components": [
    {
      "uid": "net.minecraft",
      "version": "1.21.10"
    },
    {
      "uid": "net.fabricmc.fabric-loader",
      "version": "0.18.4"
    }
  ]
}
EOF
fi

# ---- Install mods ----
rm -rf "$MC_DIR/mods"
cp -r "$MC_INSTALLER_DATA/mods" "$MC_DIR/mods"

# ---- Launch instance ----
QT_QPA_PLATFORM=xcb \
flatpak run \
org.prismlauncher.PrismLauncher \
--launch "$INSTANCE_NAME"
