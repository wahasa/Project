#!/data/data/com.termux/files/usr/bin/bash
pkg install root-repo x11-repo
pkg install proot -y
termux-setup-storage

wget https://raw.githubusercontent.com/wahasa/Ubuntu/main/Patch/audiofix.sh && chmod +x audiofix.sh && ./audiofix.sh

folder=rocky-fs
if [ -d "$folder" ]; then
        first=1
        echo "skipping downloading"
fi
tarball="rocky-rootfs.tar.xz"
if [ "$first" != 1 ];then
        if [ ! -f $tarball ]; then
                echo "Download Rootfs, this may take a while base on your internet speed."
                case `dpkg --print-architecture` in
                aarch64)
                        archurl="arm64" ;;
                #arm)
                #       archurl="armhf" ;;
                amd64)
                        archurl="amd64" ;;
                x86_64)
                        archurl="amd64" ;;
                *)
                        echo "unknown architecture"; exit 1 ;;
                esac
                wget https://raw.githubusercontent.com/wahasa/Project/main/Linux/Rocky/r8-${archurl}.sh && chmod +x r8-${archurl}.sh && ./r8-${archurl}.sh
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
bin=.rocky
linux=rocky
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
   echo "Updating Rocky,.."
   echo " "
echo "#!/bin/bash
yum update -y
yum install ncurses nano -y
clear
echo " "
echo "You can now start Rocky with 'rocky' script next time"
echo " "
rm -rf ~/.bash_profile" > $folder/root/.bash_profile   
   rm rocky8.sh
   rm audiofix.sh
bash $bin
