#!/bin/bash
clear
wget -q https://raw.githubusercontent.com/wahasa/Project/main/Installer/Linux -P ../usr/bin/
wget -q https://raw.githubusercontent.com/wahasa/Project/main/Installer/Install -P ../usr/bin/
chmod +x ../usr/bin/Linux
chmod +x ../usr/bin/Install
echo ""
echo "Installation successful,."
echo ""
rm install.sh
