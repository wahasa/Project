#!/bin/bash
rm ../usr/bin/Install
rm ../usr/bin/Linux
wget -q https://raw.githubusercontent.com/wahasa/Project/main/Installer/Linux -P ../usr/bin/
wget -q https://raw.githubusercontent.com/wahasa/Project/main/Installer/Install -P ../usr/bin/
chmod +x ../usr/bin/Linux
chmod +x ../usr/bin/Install
echo ""
echo "Updating list successful,."
echo ""
Linux List
rm update.sh
