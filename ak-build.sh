#!/bin/bash

clear

param=$1

if [ "${param}" == "debug" ]; then

 echo ""; echo "# AK BUILD DEBUG ------------------------------------------------------------------------------------------------"; echo ""

 #
 # CREATE DEF CONFIG
 # FOR TUNA KERNEL
 #
 make clean
 sleep 3
 make distclean
 sleep 3

 echo ""
 rm -rfv .config
 rm -rfv .config.old
 echo ""

 make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.6.x-google/bin/arm-eabi- ARCH=arm tuna_ak_debug_defconfig

 #
 # LOCAL KERNEL VERSION
 # PRINT THIS AFTER MAKEFILE VERSION
 #
 ak_ver="ak.666.debug"
 export LOCALVERSION="~"`echo $ak_ver`

 debug=1

else

 echo ""; echo "# AK BUILD FULL ------------------------------------------------------------------------------------------------"; echo ""

 #
 # CREATE DEF CONFIG
 # FOR TUNA KERNEL
 #
 make clean
 sleep 3
 make distclean
 sleep 3

 echo ""
 rm -rfv .config
 rm -rfv .config.old
 echo ""

 #make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.6.x-google/bin/arm-eabi- ARCH=arm cyanogenmod_ak_defconfig
 #make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.07-20120725/bin/arm-linux-gnueabihf- ARCH=arm cyanogenmod_tuna_defconfig
 #make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.08-20120827/bin/arm-linux-gnueabihf- ARCH=arm cyanogenmod_ak_defconfig
 #make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.09-20120921/bin/arm-linux-gnueabihf- ARCH=arm cyanogenmod_ak_defconfig
 make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.10-20121023/bin/arm-linux-gnueabihf- ARCH=arm tuna_ak_defconfig

 #
 # LOCAL KERNEL VERSION
 # PRINT THIS AFTER MAKEFILE VERSION
 #
 ak_ver="ak.304.berserk"
 export LOCALVERSION="~"`echo $ak_ver`

 debug=0

fi

#
# FIRST GENERATE .config FILE
# AND THEN CROSS COMPILE KERNEL MODULES
#

#make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.6.x-google/bin/arm-eabi- ARCH=arm -j4 modules
#make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.07-20120725/bin/arm-linux-gnueabihf- ARCH=arm -j4 modules
#make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.08-20120827/bin/arm-linux-gnueabihf- ARCH=arm -j4 modules
#make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.09-20120921/bin/arm-linux-gnueabihf- ARCH=arm -j4 modules
make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.10-20121023/bin/arm-linux-gnueabihf- ARCH=arm -j4 modules

#
# FIND .KO MODULE CREATE WITH CROSS COMPILE
# AND THEN COPY .KO MODULE TO CWM SCRIPT
#

echo ""
rm -rfv /root/android/AK-Kernel/AK-ramdisk/cwm/system/lib/modules/*
find /root/android/AK-Kernel/AK-berserk/ -name '*.ko' -exec cp -v {} /root/android/AK-Kernel/AK-ramdisk/cwm/system/lib/modules \;
#/root/android/AK-Kernel/AK-linaro/4.6.x-google/bin/arm-eabi-strip --strip-debug /root/android/AK-Kernel/AK-ramdisk/cwm/system/lib/modules/*.ko
#/root/android/AK-Kernel/AK-linaro/4.7.2-2012.07-20120725/bin/arm-linux-gnueabihf-strip --strip-debug /root/android/AK-Kernel/AK-ramdisk/ramdisk-cm10/sbin/files/modules/*.ko
#/root/android/AK-Kernel/AK-linaro/4.7.2-2012.08-20120827/bin/arm-linux-gnueabihf-strip --strip-debug /root/android/AK-Kernel/AK-ramdisk/cwm/system/lib/modules/*.ko
#/root/android/AK-Kernel/AK-linaro/4.7.2-2012.09-20120921/bin/arm-linux-gnueabihf-strip --strip-debug /root/android/AK-Kernel/AK-ramdisk/cwm/system/lib/modules/*.ko
/root/android/AK-Kernel/AK-linaro/4.7.2-2012.10-20121023/bin/arm-linux-gnueabihf-strip --strip-debug /root/android/AK-Kernel/AK-ramdisk/cwm/system/lib/modules/*.ko
echo ""

#
# CROSS COMPILE KERNEL WITH TOOLCHAIN
# REMEMBER TO SET CONFIG_INITRAMFS_SOURCE DIR
#

#make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.6.x-google/bin/arm-eabi- ARCH=arm -j4 zImage
#make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.07-20120725/bin/arm-linux-gnueabihf- ARCH=arm -j4 zImage
#make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.08-20120827/bin/arm-linux-gnueabihf- ARCH=arm -j4 zImage
#make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.09-20120921/bin/arm-linux-gnueabihf- ARCH=arm -j4 zImage
make CROSS_COMPILE=/root/android/AK-Kernel/AK-linaro/4.7.2-2012.10-20121023/bin/arm-linux-gnueabihf- ARCH=arm -j4 zImage

#
# COPY ZIMAGE OF KERNEL
# FOR MERGE RAMDISK
#

cp -vr arch/arm/boot/zImage ../AK-ramdisk/

cd ../AK-ramdisk/ramdisk-cm10/
chmod 750 init* charger
chmod 644 default.prop
chmod 640 fstab.tuna
chmod 644 ueventd*

cd ..
./repack-bootimg.pl zImage ramdisk-cm10/ boot.img
cp -vr boot.img cwm/

#
# CREATE A CWM PKG
# FOR FLASH FROM RECOVERY
#

cd cwm
zip -r `echo $ak_ver`.zip *
rm -rf /home/anarkia/Scrivania/AK-Kernel/`echo $ak_ver`.zip
cp -vr `echo $ak_ver`.zip /home/anarkia/Scrivania/AK-Kernel/
mv `echo $ak_ver`.zip ../zip/
rm -rf `echo $ak_ver`.zip boot.img

cd ..
cd ../AK-berserk/

echo .
echo ..
echo ... Compile Complite ! ... `echo $ak_ver`.zip
echo ..
echo .
e\cho ""
