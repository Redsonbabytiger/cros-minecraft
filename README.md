Cros-Minecraft

Cros-Minecraft is a custom Minecraft launcher setup designed for ChromeOS (Crostini) and Linux, making it easy to install, manage, and launch modded Minecraft instances without manual configuration.

Latest Release: v3 ✅

Features in v3

Version 3 introduces fully automated instance creation and Fabric mod support, powered by Prism Launcher:

✅ Automatic Fabric instance creation

✅ Minecraft version 1.21 preconfigured

✅ Auto-copy of your mods into the instance

✅ One-command launch — no GUI clicks needed after first login

✅ Flatpak-safe, works on Crostini/Linux without Wayland issues

These features make it easier than ever to run modded Minecraft on ChromeOS or Linux.

Installation

Run the installation script (cros-minecraft-moderninstall.sh) to set up everything:

bash cros-minecraft-moderninstall.sh


The script will:

Install required dependencies (flatpak, libgl-image-display0, libgle3)

Install Prism Launcher via Flatpak

Download the modpack and setup directories

Automatically create a Fabric instance

Copy your mods to the instance

Launch the instance

After the first login, launching your modded Minecraft is as simple as:

./cros-minecraft-moderninstall.sh

Usage

Place your mods in Linux Backups/mods

Run the install script once for setup

Subsequent runs will launch Minecraft automatically

Directory Structure

After installation, your Minecraft instance lives in:

~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/PerfFabric


minecraft/ → Minecraft game files

minecraft/mods/ → Your copied mods

instance.cfg → Instance configuration

mmc-pack.json → Fabric + Minecraft version config

Requirements

ChromeOS (Crostini) or Linux (Debian/Ubuntu tested)

Flatpak installed

Internet connection for Minecraft downloads

Java detected by Prism Launcher

Notes

First launch requires logging in via Prism Launcher GUI for authentication

Supports Minecraft 1.21 with Fabric Loader

Designed to prevent Wayland/X11 crashes on Crostini

Contributing

Pull requests and feature suggestions are welcome!
If you find bugs or have modpack compatibility suggestions, open an issue.