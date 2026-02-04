Cros-Minecraft

Cros-Minecraft is a custom Minecraft launcher setup designed for ChromeOS (Crostini) and Debian Linux, making it easy to install and launch Minecraft without manual configuration.

Latest Release: v3 ✅

Features in v3

Version 3 introduces fully automated instance creation and Fabric mod support, powered by Prism Launcher:

✅ Automatic Fabric instance creation

✅ Minecraft version 1.21.10 preconfigured

✅ Auto-copy performance mods into the instance

✅ One-command launch — no GUI clicks needed after first login

✅ Flatpak-safe, works on Crostini/Debian without Wayland issues

These features make it easier than ever to run Minecraft on ChromeOS or Debian.

Installation

Run the installation script (cros-minecraft if you installed the package) to set up everything:

cros-minecraft

The script will:

Install required dependencies (flatpak, libgl-image-display0, libgle3)

Install Prism Launcher via Flatpak

Download the modpack and setup directories

Automatically create a Fabric instance

Copy the performance mods to the instance

After the first login, launching your modded Minecraft is as simple as:

cros-minecraft --run

Usage

Find and install the latest release of cros-minecraft (currently v3)

Run the install script once for setup

When the script asks for which installation method, choose Modern Launcher (for prism launcher)

Use "cros-minecraft --run" to launch minecraft directly

Directory Structure

After installation, your Minecraft instance lives in:

~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/PerfFabric

minecraft/ → Minecraft game files

minecraft/mods/ → The performance mods and any other mods you might add yourself

instance.cfg → Instance configuration

mmc-pack.json → Fabric + Minecraft version config

Requirements

ChromeOS (Crostini) or Linux (Debian/Ubuntu tested)

Internet connection for Minecraft downloads

You must run the main cros-minecraft command and agree to download the recommended packages as those are the packages needed by minecraft and the installer script.

Notes

First launch requires logging in via Prism Launcher GUI for authentication

Supports Minecraft 1.21.10 with Fabric Loader only

Designed to prevent Wayland/X11 crashes on Crostini

Contributing

Pull requests and feature suggestions are welcome!
If you find bugs or have modpack compatibility suggestions, open an issue.
If you would like to suggest other performance mods / other versions of minecraft, open an issue.
