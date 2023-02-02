
#!/data/data/com.termux/files/usr/bin/bash
pkg install root-repo x11-repo
pkg install proot -y
termux-setup-storage

wget https://raw.githubusercontent.com/wahasa/Ubuntu/main/Patch/audiofix.sh && chmod +x audiofix.sh && ./audiofix.sh

folder=centos-fs
if [ -d "$folder" ]; then
        first=1
        echo "skipping downloading"
fi
tarball="centos-rootfs.tar.gz"
if [ "$first" != 1 ];then
        if [ ! -f $tarball ]; then
                echo "Download Rootfs, this may take a while base on your internet speed."
                case `dpkg --print-architecture` in
                aarch64)
                        archurl="aarch64" ;;
                arm)
                        archurl="armhfp" ;;
                amd64)
                        archurl="x86_64" ;;
                x86_64)
                        archurl="x86_64" ;;
                *)
                        echo "unknown architecture"; exit 1 ;;
                esac
                wget "https://github.com/CentOS/sig-cloud-instance-images/blob/b2d195220e1c5b181427c3172829c23ab9cd27eb/docker/centos-7-${archurl}-docker.tar.xz?raw=true" -O $tarball
                wget "https://github.com/CentOS/sig-cloud-instance-images/blob/8022ae6d18ddf031b1b3a80549eeb46d1deb6dcd/docker/centos-7${archurl}-docker.tar.xz?raw=true" -O $tarball
                wget "https://github.com/CentOS/sig-cloud-instance-images/blob/02ea5808a8a155bad28677dd5857c8d382027e14/docker/centos-7-${archurl}-docker.tar.xz?raw=true" -O $tarball
        fi
        cur=`pwd`
        mkdir -p "$folder"
        cd "$folder"
        echo "Decompressing Rootfs, please be patient."
        proot --link2symlink tar -xf ${cur}/${tarball}||:
        cd "$cur"
   fi
   chmod 755 -R ~/$folder
   echo "localhost" > ~/"$folder"/etc/hostname
   echo "127.0.0.1 localhost" > ~/"$folder"/etc/hosts
   echo "nameserver 8.8.8.8" > ~/"$folder"/etc/resolv.conf
mkdir -p $folder/binds
bin=.centos
linux=centos
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
command+=" LANG=C.UTF-8"
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
   echo "bash $bin" > $PREFIX/bin/$linux
   chmod +x $PREFIX/bin/$linux
   echo "Removing image for some space"
   #rm $tarball
   clear
   echo " "
   echo "Add Centos Package,.."
   echo " "
echo "#!/bin/bash
yum install  nano -y
clear
echo " "
echo "You can now start Centos with 'centos' script next time"
echo " "
rm -rf ~/.bash_profile" > $folder/root/.bash_profile
   rm centos7.sh
   rm audiofix.sh
bash $bin
