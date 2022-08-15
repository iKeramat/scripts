red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
LOCAL_DIR=$(pwd)

# check cross-compilers dir
CROSS_COMPILERS=$(pwd)/cross-compilers
if [ -d "$CROSS_COMPILERS" ]; then
    echo "${red}cross-compilers are ready!${reset}"
else
    git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/ -b android-12.1.0_r22 cross-compilers/clang-12
    git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 -b lineage-18.1 cross-compilers/gcc/aarch64/aarch64-linux-android-4.9
    git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 -b lineage-18.1 cross-compilers/gcc/arm/arm-linux-androideabi-4.9
fi

# set path of cross-compilers
PATH="$(pwd)/cross-compilers/clang-12/bin:$(pwd)/cross-compilers/gcc/aarch64/aarch64-linux-android-4.9/bin:$(pwd)/cross-compilers/gcc/arm/arm-linux-androideabi-4.9/bin:${PATH}" 

# goto kernel source
read -p "Enter your kernel source dir: "  KERNEL_SOURCE
cd $KERNEL_SOURCE

# get device defconfig
read -p "Enter your device defconfig: "  defconfig
echo "Your defconfig is ${red}$defconfig${reset}"

# clean out dir
rm -rf ../output && mkdir ../output

# make defconfig
make O=../output ARCH=arm64 $defconfig

# start building ...
make -j$(nproc --all) O=../output ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- CROSS_COMPILE_ARM32=arm-linux-androideabi-

# goto local dir
cd $LOCAL_DIR

# check anykernel dir
ANYKERNEL=$(pwd)/anykernel
if [ -d "$ANYKERNEL" ]; then
    echo "${red}anykernel is available.${reset}"
else
    git clone https://github.com/iKeramat/AnyKernel3 anykernel
fi

# set device codeame 1
if grep -i "device.name1=maguro" anykernel/anykernel.sh; then
   read -p "Enter device codename1: "  codename1
   sed -i s/device.name1=maguro/device.name1=$codename1/g anykernel/anykernel.sh
fi

# set device codeame 2
if grep -i "device.name2=toro" anykernel/anykernel.sh; then
   read -p "Enter device codename2: "  codename2
   sed -i s/device.name2=toro/device.name2=$codename2/g anykernel/anykernel.sh
fi

# set device codeame 3
if grep -i "device.name3=toroplus" anykernel/anykernel.sh; then
   read -p "Enter device codename3: "  codename3
   sed -i s/device.name3=toroplus/device.name3=$codename3/g anykernel/anykernel.sh
fi

# set device codeame 4
if grep -i "device.name4=tuna" anykernel/anykernel.sh; then
   read -p "Enter device codename4: "  codename4
   sed -i s/device.name4=tuna/device.name4=$codename4/g anykernel/anykernel.sh
fi

# set kernel name
if grep -i "kernel.string=ExampleKernel by osm0sis @ xda-developers" anykernel/anykernel.sh; then
   # get kernel name
   read -p "Enter your kernel name: "  kernelname
   sed -i s/'kernel.string=ExampleKernel by osm0sis @ xda-developers'/kernel.string=$kernelname/g anykernel/anykernel.sh
fi

cp $KERNEL_SOURCE/../output/arch/arm64/boot/Image.gz-dtb $ANYKERNEL

# set date and time
export DATE_TIME="${d-`date "+%m%d-%H%M%S"`}"
cd anykernel

# create flashable zip
zip -r9 $kernelname-$DATE_TIME.zip * -x README.md $kernelname-$DATE_TIME.zip

# Say build is done
echo "${green}Your build is successfully finished checkout flashable zip at: $(pwd)/anykernel/Kernel-$DATE_TIME.zip${reset}"

