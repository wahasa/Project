#!/data/data/com.termux/files/usr/bin/bash
pkg install root-repo x11-repo
pkg install proot -y
termux-setup-storage

wget https://raw.githubusercontent.com/wahasa/Ubuntu/main/Patch/audiofix.sh && chmod +x audiofix.sh && ./audiofix.sh

folder=manjaro-fs
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="manjaro-rootfs.tar.xz"
if [ "$first" != 1 ];then
	if [ ! -f $tarball ]; then
         	echo "Download Rootfs, this may take a while base on your internet speed."
    		case `dpkg --print-architecture` in
    		aarch64)
      			archurl="aarch64" ;;
    		#arm)
    		#  archurl="armhf" ;;
    		#amd64)
    		#  archurl="amd64" ;;
    		#x86_64)
    		#  archurl="amd64" ;;
    		*)
      			echo "unknown architecture"; exit 1 ;;
    		esac
    		wget "https://github.com/manjaro-arm/rootfs/releases/download/20230123/Manjaro-ARM-${archurl}-latest.tar.gz" -O $tarball
	fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	proot --link2symlink tar -xf ${cur}/$tarball --exclude='dev'|| :
	cd "$cur"
fi
  echo "localhost" > ~/"$folder"/etc/hostname
  echo "127.0.0.1 localhost" > ~/"$folder"/etc/hosts
  echo "nameserver 8.8.8.8" > ~/"$folder"/etc/resolv.conf
mkdir -p $folder/binds
bin=.manjaro
linux=manjaro
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
pulseaudio -k >> /dev/null 2>&1
pulseaudio --start >> /dev/null 2>&1
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --kill-on-exit"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A $folder/binds)" ]; then
    for f in $folder/binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b $folder/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=en_US.UTF-8"
command+=" LC_ALL=C"
command+=" LANGUAGE=en_US"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM
   echo "Fixing shebang of $linux"
   termux-fix-shebang $bin
   echo "Making $linux executable"
   chmod +x $bin
   echo "Fixing permissions for $linux"
   chmod 755 -R ~/$folder
   echo "bash $bin" > $PREFIX/bin/$linux
   chmod +x $PREFIX/bin/$linux
   echo "Removing image for some space"
   #rm $tarball
cat >$folder/etc/pacman.d/mirrorlist <<'EOL'
##
## Manjaro Linux repository mirrorlist
## Generated on 02 May 2020 14:22
##
## Use pacman-mirrors to modify
##
## Location  : Germany
## Time      : 99.99
## Last Sync :
Server = https://mirrors.dotsrc.org/manjaro/arm-stable/$repo/$arch
EOL
   clear
   echo " "
   echo "Add Manjaro Package,.."
   echo " "
echo "#!/bin/bash
pacman-key --init && pacman-key --populate
pacman -Sy && pacman -S nano --noconfirm
clear
echo " "
echo "You can now start Manjaro with 'manjaro' script next time"
echo " "
rm -rf ~/.bash_profile" > $folder/root/.bash_profile   
   rm manjaro.sh
   rm audiofix.sh
bash $bin
