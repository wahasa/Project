#!/bin/bash
wget -q https://raw.githubusercontent.com/wahasa/Project/main/Installer/Linux -P ../usr/bin/
wget -q https://raw.githubusercontent.com/wahasa/Project/main/Installer/Install -P ../usr/bin/
wget -q https://raw.githubusercontent.com/wahasa/Project/main/Uninstaller/Uninstall -P ../usr/bin/
chmod +x ../usr/bin/Linux
chmod +x ../usr/bin/Install
chmod +x ../usr/bin/Uninstall
echo "Installation successful,."
echo ""
sleep 1
echo -n ""
echo -n "L"
sleep 1
echo -n "o"
sleep 1
echo -n "a"
sleep 1
echo -n "d"
sleep 1
echo -n "i"
sleep 1
echo -n "n"
sleep 1
echo -n "g"
sleep 1
echo -n ","
sleep 1
echo -n "."
sleep 1
echo -n "."
sleep 1
rm ../usr/bin/Install.*
rm ../usr/bin/Linux.*
rm ../usr/bin/Uninstall.*
clear
Linux
rm install.sh
