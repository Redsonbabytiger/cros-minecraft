#!/bin/bash
#set -e

# ---- Dependencies ----
sudo apt install -y flatpak libgl-image-display0 libgle3 curl jq
flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ---- Force X11 (prevents Wayland crashes on Crostini) ----
export QT_QPA_PLATFORM=xcb

# ---- Install Prism Launcher ----
flatpak install -y flathub org.prismlauncher.PrismLauncher

# ---- Ask User About Custom Config ----
echo -e "\e[36mWhat version of minecraft would you like? (Default is 1.21.10)\e[0m"
read -p 'Press ENTER for default or type a version: ' action
if [[ -z "$action" || "$action" == "y" ]]; then
  MC_VERSION="1.21.10"
  FABRIC_LOADER_VERSION="0.18.4"
else
  MC_VERSION="$action"
  FABRIC_LOADER_VERSION="0.18.4"
fi

# ---- Paths ----
PRISM_DIR="$HOME/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher"
INSTANCES_DIR="$PRISM_DIR/instances"
INSTANCE_NAME="PerfFabric-$MC_VERSION"
INSTANCE_DIR="$INSTANCES_DIR/$INSTANCE_NAME"
MC_DIR="$INSTANCE_DIR/minecraft"
MC_INSTALLER_DATA="$HOME/cros-minecraft-packages"
MODS_DIR="$MC_INSTALLER_DATA/mods"
USER_AGENT="Redsonbabytiger/Cros-Minecraft/3.1"
LOADER="fabric"

# ---- Mod Fetching Function ----
mkdir -p "$MC_DIR/mods"

# List of mods to install
MOD_LIST=(
sodium
lithium
ferrite-core
starlight
lazydfu
modernfix
immediatelyfast
cloth-config
crash-assistant
fabric-api
worldedit
ixeris
jade
moreculling
architectury-api
)

install_mod() {

    MOD_SLUG="$1"

    echo "Checking $MOD_SLUG..."

    # use --get with urlencode to avoid mis-formatted params
    RESPONSE=$(curl -s --get \
    -H "User-Agent: $USER_AGENT" \
    --data-urlencode "loaders=[\"$LOADER\"]" \
    --data-urlencode "game_versions=[\"$MC_VERSION\"]" \
    "https://api.modrinth.com/v2/project/$MOD_SLUG/version")

    # if API didn't return anything useful, bail early
    if [ -z "$RESPONSE" ] || [ "$RESPONSE" == "[]" ]; then
        echo "No version information returned for $MOD_SLUG (response: $RESPONSE)"
        return
    fi

    FILE_URL=$(echo "$RESPONSE" | jq -r '.[0].files[0].url')
    FILE_NAME=$(echo "$RESPONSE" | jq -r '.[0].files[0].filename')

    # guard against empty or null URLs which cause curl errors
    if [ -z "$FILE_URL" ] || [ "$FILE_URL" == "null" ]; then
        echo "No compatible version found for $MOD_SLUG"
        return
    fi

    if [ -f "$MODS_DIR/$FILE_NAME" ]; then
        echo "$FILE_NAME already installed"
    else
        echo "Downloading $FILE_NAME..."
        curl -L -H "User-Agent: $USER_AGENT" "$FILE_URL" -o "$MODS_DIR/$FILE_NAME"
    fi

    # Install dependencies
    DEP_IDS=$(echo "$RESPONSE" | jq -r '.[0].dependencies[]? | select(.dependency_type=="required") | .project_id')

    for DEP in $DEP_IDS; do
        DEP_SLUG=$(curl -s \
        -H "User-Agent: $USER_AGENT" \
        "https://api.modrinth.com/v2/project/$DEP" \
        | jq -r '.slug')

        install_mod "$DEP_SLUG"
    done
}

for MOD in "${MOD_LIST[@]}"; do
    install_mod "$MOD"
done

echo "All mods installed!"

# ---- Download mod pack data ----
if [ ! -d "$MC_INSTALLER_DATA" ]; then
  echo "Cros-Minecraft Installer Data folder not found, downloading it..."
  gdown "1S0O37qCyuVO1Oka23sO4P5aryYSg0-Xv" --folder -O "$MC_INSTALLER_DATA"
fi

# ---- Create instance structure (ONLY if missing) ----
if [ ! -d "$INSTANCE_DIR" ]; then

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
      "version": "$MC_VERSION"
    },
    {
      "uid": "net.fabricmc.fabric-loader",
      "version": "$FABRIC_LOADER_VERSION"
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
