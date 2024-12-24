#!/bin/sh
# Compile script for Compiling kernel
# Copyright (c) RapliVx Aka Rafi Aditya

# Setup
PHONE="Lavender"
DEFCONFIG=lavender-perf_defconfig
COMPILERDIR="$(pwd)/../proton-clang"
CLANG="Proton Clang"
CODENAME="[Shogun]"
ZIPNAME="InazumaKernel-$CODENAME-Lavender-$(date '+%Y%m%d-%H%M').zip"
CAPTION="Inazuma Kernel Compile Complete"
BOT_TOKEN="-"
CHAT_ID="-"
MESSAGE="• Build For $PHONE Started •"
MESSAGE_ERROR="• Error Build For $PHONE Aborted •"
export KBUILD_BUILD_USER=Rapli
export KBUILD_BUILD_HOST=ArchLinux

# Header
cyan="\033[96m"
green="\033[92m"
red="\033[91m"
blue="\033[94m"
yellow="\033[93m"

echo -e "$cyan===========================\033[0m"
echo -e "$cyan= START COMPILING KERNEL  =\033[0m"
echo -e "$cyan===========================\033[0m"

echo -e "$blue...KSABAR...\033[0m"

echo -e -ne "$green== (10%)\r"
sleep 0.7
echo -e -ne "$green=====                     (33%)\r"
sleep 0.7
echo -e -ne "$green=============             (66%)\r"
sleep 0.7
echo -e -ne "$green=======================   (100%)\r"
echo -ne "\n"

echo -e -n "$yellow\033[104mPRESS ENTER TO CONTINUE\033[0m"
read P
echo  $P

# Clone Proton Clang
if [ -d $COMPILERDIR ] ; then
echo -e "\n $green[!] Lets's Build UwU...\033[0m \n"
else
echo -e "\n $red[!] Proton-clang Dir Not Found!!!\033[0m \n"
sleep 2
echo -e "$green[+] Wait.. Cloning Proton-clang...\033[0m \n"
sleep 2
git clone --depth=1 https://github.com/kdrag0n/proton-clang.git $COMPILERDIR
sleep 1
echo
echo -e "\n $green [!] Lets's Build UwU...\033[0m \n"
sleep 1
fi

# URL API Telegram untuk mengirim pesan
URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

# Data yang akan dikirimkan
DATA="chat_id=$CHAT_ID&text=$MESSAGE"
DATA_ERR="chat_id=$CHAT_ID&text=$MESSAGE_ERROR"

# Kirim permintaan POST ke API Telegram
curl -s -X POST "$URL" -d "$DATA"

# setup dir
KERN_IMG="out/arch/arm64/boot/Image.gz-dtb" # Direktori image-gz.dtb atau image.gz kernel

function clean() {
    echo -e "\n"
    echo -e "$red [!] CLEANING UP \\033[0m"
    echo -e "\n"
    rm -rf out
    make mrproper
}

# Make Defconfig

function build_kernel() {
    export PATH="$COMPILERDIR/bin:$PATH"
    make -j$(nproc --all) O=out ARCH=arm64 ${DEFCONFIG}
    if [ $? -ne 0 ]
then
    echo -e "\n"
    echo -e "$red [!] BUILD FAILED \033[0m"
    echo -e "\n"
else
    echo -e "\n"
    echo -e "$green==================================\033[0m"
    echo -e "$green= [!] START BUILD ${DEFCONFIG}\033[0m"
    echo -e "$green==================================\033[0m"
    echo -e "\n"
fi

# Build Start Here

   make -j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    AR=llvm-ar \
    NM=llvm-nm \
    LD=ld.lld \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CC=clang \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee log.txt
    
    # Zipping

    if [ -e "$KERN_IMG" ]; then
            echo -e "$green=============================================\033[0m"
            echo -e "$green= [+] Zipping up ...\033[0m"
            echo -e "$green=============================================\033[0m"
    if [ -d "$AK3_DIR" ]; then
            cp -r $AK3_DIR AnyKernel3
        elif ! git clone -q https://github.com/RapliVx/AnyKernel3.git -b lavender; then
                echo -e "\nAnyKernel3 repo not found locally and couldn't clone from GitHub! Aborting..."
        fi
            cp $KERN_IMG AnyKernel3
            cd AnyKernel3
            git checkout lavender &> /dev/null
            zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
            cd ..
            rm -rf AnyKernel3
    fi


    if [ -e "$ZIPNAME" ] ; then
    echo -e "$green===========================\033[0m"
    echo -e "$green=  SUCCESS COMPILE KERNEL \033[0m"
    echo -e "$green=  Device     : $PHONE \033[0m"
    echo -e "$green=  Defconfig  : $DEFCONFIG \033[0m"
    echo -e "$green=  Toolchain  : $CLANG \033[0m"
    echo -e "$green=  Codename   : $CODENAME \033[0m"
    echo -e "$green=  New Driver : $ZIPNAME \033[0m"
    echo -e "$green=  Completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) \033[0m "
    echo -e "$green=  Have A Brick Day Nihahahah \033[0m"
    echo -e "$green===========================\033[0m"
    else
    echo -e "$red [!] FIX YOUR KERNEL SOURCE BRUH !?\033[0m"
    curl -s -X POST "$URL" -F document=@"log.txt" -F caption="$DATA_ERR" -F chat_id="$CHAT_ID"
    fi

    if [ -e "$ZIPNAME" ] ; then 
    echo -e "$green=============================================\033[0m"
    echo -e "$green= [+] Uploading ...\033[0m"
    echo -e "$green=============================================\033[0m"

    URL="https://api.telegram.org/bot$BOT_TOKEN/sendDocument"

    curl -s -X POST "$URL" -F document=@"$ZIPNAME" -F caption="$CAPTION" -F chat_id="$CHAT_ID"

    fi
}

# execute
clean
build_kernel