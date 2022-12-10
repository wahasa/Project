#!/bin/bash
rm ../usr/bin/Install
rm ../usr/bin/Linux
wget -q https://raw.githubusercontent.com/wahasa/Project/main/Installer/Linux -P ../usr/bin/
wget -q https://raw.githubusercontent.com/wahasa/Project/main/Installer/Install -P ../usr/bin/
wget -q https://raw.githubusercontent.com/wahasa/Project/main/Uninstaller/Uninstall -P ../usr/bin/
chmod +x ../usr/bin/Linux
chmod +x ../usr/bin/Install
echo "Updating list successful,."
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
sleep 2
clear
Linux List
rm update.sh
