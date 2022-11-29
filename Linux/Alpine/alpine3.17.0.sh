#!/data/data/com.termux/files/usr/bin/bash
pkg install root-repo x11-repo
pkg install pv proot -y
termux-setup-storage

wget https://raw.githubusercontent.com/wahasa/Ubuntu/main/Patch/audiofix.sh && chmod +x audiofix.sh && ./audiofix.sh

linux=alpine
folder=alpine-fs
tarball="alpine-rootfs.tar.gz"
mkdir -p $folder $folder/binds
[ -f $tarball ] && check=1
if [ "$check" -eq "1" ] > /dev/null 2>&1; then
	echo "Please Waiting,."
	if [ -x "$(command -v neofetch)" ]; then
		neofetch --ascii_distro Alpine -L
	fi
	pv $tarball | proot --link2symlink tar -zxf - -C $folder || :
else
	case `dpkg --print-architecture` in
	aarch64)
		archurl="aarch64" ;;
	arm)
		archurl="armhf" ;;
	amd64)
		archurl="x86_64" ;;
	x86_64)
		archurl="x86_64" ;;
	*)
		echo "unknown architecture"; exit 1 ;;
	esac
	url=https://dl-cdn.alpinelinux.org/alpine/v3.17/releases/${archurl}/alpine-minirootfs-3.17.0-${archurl}.tar.gz
	echo "Downloading and Extracting Rootfs,."
	echo ""
	if [ -x "$(command -v neofetch)" ]; then
		neofetch --ascii_distro Alpine -L
	fi
	wget -qO- --tries=0 $url --show-progress --progress=bar:force:noscroll |proot --link2symlink tar -zxf - -C $folder --exclude='dev' || :
fi
bin=.alpine
if [ -d $folder/var ];then
	echo ""
	echo "Writing launch script"
	echo ""

	cat > $bin <<- EOM
	#!/data/data/com.termux/files/usr/bin/bash
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
	command+=" PATH=/bin:/usr/bin:/sbin:/usr/sbin"
	command+=" TERM=\$TERM"
	command+=" LANG=en_US.UTF-8"
	command+=" LC_ALL=C"
	command+=" LANGUAGE=en_US"
	command+=" /bin/sh --login"
	com="\$@"
	if [ -z "\$1" ];then
    		exec \$command
	else
    		\$command -c "\$com"
	fi
	EOM

	if test -f "$bin"; then
  		echo "Fixing shebang of $linux"
		chmod +x $bin
		termux-fix-shebang $bin
		echo "bash $bin" > $PREFIX/bin/$linux
   		chmod +x $PREFIX/bin/$linux
	fi

	FD=$folder
	if [ -d "$FD" ]; then
  		echo "Making $linux executable"
		#chmod +x $bin
	fi

	UFD=$folder/binds
	if [ -d "$UFD" ]; then
  		echo "Removing image for some space"
		#rm $tarball
	fi

	echo ""
	echo "" > $folder/etc/fstab
	rm -rf $folder/etc/resolv.conf
	echo "localhost" > ~/"$folder"/etc/hostname
   	echo "127.0.0.1 localhost" > ~/"$folder"/etc/hosts
	echo "nameserver 8.8.8.8" > ~/"$folder"/etc/resolv.conf
        ./$bin apk update
        ./$bin apk add --no-cache bash
        sed -i 's/ash/bash/g' $folder/etc/passwd
        sed -i 's/bin\/sh/bin\/bash/g' $bin
	echo ""
	echo "Installation Finished"
	rm -rf $folder/root/.bash_profile
	clear
	echo " "
	echo "Updating Alpine,.."
	echo " "
  	echo "#!/bin/bash
	apk update && apk upgrade
	apk add nano
	clear
	echo ""
        echo "You can now start Alpine with 'alpine' script next time"
	echo ""
	rm -rf ~/.bash_profile" > $folder/root/.bash_profile  
	rm alpine3.17.0.sh
	rm audiofix.sh
	bash $bin
else
	echo "Installation unsuccessful"
fi
