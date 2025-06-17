#!/bin/bash

# === SAFER SYSTEM CLEANUP & SETUP SCRIPT ===
# Target: Ubuntu 24.04 with GNOME
# Author: Your future self who doesn’t want to break shit

# --- Bloatware (safe to remove) ---
echo "[INFO] Removing optional bloat packages..."

safe_remove_list=(
  yelp
  gnome-logs
  gnome-weather
  seahorse
  gnome-contacts
  geary
  ibus-mozc
  mozc-utils-gui
  simple-scan
  popsicle
  popsicle-gtk
  xfburn
  xsane
  hv3
  exfalso
  parole
  quodlibet
  redshift
  drawing
  hexchat
  transmission-gtk
  webapp-manager
  celluloid
  hypnotix
  rhythmbox
  aisleriot
  gnome-mahjongg
  gnome-mines
  quadrapassel
  gnome-sudoku
  pitivi
  gnome-sound-recorder
  remmina
  zorin-windows-app-support-installation-shortcut
)

for pkg in "${safe_remove_list[@]}"; do
  echo "[INFO] Trying to remove: $pkg"
  sudo apt --purge remove -y "$pkg" || echo "[WARN] $pkg failed or not installed"
done

# DO NOT REMOVE THESE (unless you know what you're doing)
# - gnome-shell
# - ubuntu-desktop
# - gdm3
# - firefox (linked to session sometimes)
# - nautilus
# - gnome-settings-daemon
# - anything evolution or rhythmbox-related (unless you’ve replaced their deps)

# --- Update & Upgrade ---
echo "[INFO] Updating and upgrading packages..."
sudo apt update
sudo apt install --fix-missing -y
sudo apt upgrade --allow-downgrades -y
sudo apt full-upgrade --allow-downgrades -y

# --- Timeshift for Backups ---
echo "[INFO] Installing Timeshift (backup tool)..."
sudo apt install -y timeshift

# --- Flatpak Support ---
echo "[INFO] Setting up Flatpak and Flathub..."
sudo apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# --- Final Cleanup ---
echo "[INFO] Final cleanup..."
sudo apt install -f
sudo apt autoremove -y
sudo apt autoclean
sudo apt clean

# --- Done ---
echo -e "\n✅ All done!"
echo "👉 You can now reboot and use Timeshift to make a system snapshot."
