#!/bin/bash
case `dpkg --print-architecture` in
      aarch64)
           archurl="arm64" ;;
      arm)
           archurl="armhf" ;;
      amd64)
           archurl="amd64" ;;
      x86_64)
           archurl="amd64" ;;
      *)
           echo "unknown architecture"; exit 1 ;;
      esac
      wget "https://raw.githubusercontent.com/wahasa/Project/main/Linux/Parrot/p5.2-${archurl}.sh"
chmod +x p5.2-${archurl}.sh
bash p5.2-${archurl}.sh
rm parrot5.2.sh
