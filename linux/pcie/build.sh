#!/bin/bash
set -euo pipefail

ARCH="arm64"
CROSS_COMPILE=/source/Gen3_251026/apps/LINUX/android/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
PWD=$(pwd)
PCIE_DRIVER_ROOT="/source/Gen3_251026/apps/LINUX/android/vendor/hailo/proprietary/hailort-drivers/linux/pcie"
PROJECT_ROOT="/source/Gen3_251026/apps/LINUX/android/vendor/hailo/proprietary/hailort-drivers"
KERNEL_DIR="/source/Gen3_251026/apps/LINUX/android/out/target/product/sm6150_au/obj/kernel/msm-4.14"
BUILD_DIR="out"
TARGET_DIR="${PCIE_DRIVER_ROOT}/${BUILD_DIR}/release/${ARCH}"
DEBUG=1

echo "Hailo 8 PCIe driver build script for Android PoC Gen3"

if [ $DEBUG -eq 1 ]; then
    echo "Debug mode is ON"
    GDB_FLAG="CONFIG_DEBUG_INFO=y CONFIG_FRAME_POINTER=y"
    TARGET_DIR="${PCIE_DRIVER_ROOT}/${BUILD_DIR}/debug/${ARCH}"
fi

echo "ARCH: $ARCH"
echo "CROSS_COMPILE: $CROSS_COMPILE"
echo "PWD: $PWD"
echo "KERNEL_DIR: $KERNEL_DIR"
echo "BUILD_DIR: $BUILD_DIR"
echo "TARGET_DIR: $TARGET_DIR"

# make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} LLVM=1 LLVM_IAS=1 -C ${KERNEL_DIR} M=${PWD} clean
#  LLVM=1 LLVM_IAS=1
# cd /source/Gen3_251026/apps/LINUX/android/out/target/product/sm6150_au/obj/kernel/msm-4.14/

function prepare {
    echo "Preparing target directory at ${TARGET_DIR}..."
    mkdir -p ${TARGET_DIR}
}

function build {
    echo "Starting driver build..."
    make \
        ARCH=${ARCH} \
        CROSS_COMPILE=${CROSS_COMPILE} \
        -C ${KERNEL_DIR} \
        M=${PWD} \
        ${GDB_FLAG} \
        KBUILD_EXTRA_SYMBOLS=${KERNEL_DIR}/Module.symvers \
        -j34 modules
    echo -e "\e[32mDriver build finished.\e[0m"
    echo ""
}

function mv_file {
    echo "Copying built module to target directory..."
    mv ${PCIE_DRIVER_ROOT}/hailo_pci.ko ${TARGET_DIR}/hailo_pci.ko
}

function signing_module {
    echo "Signing the kernel module..."
    ${KERNEL_DIR}/scripts/sign-file sha512 ${KERNEL_DIR}/certs/signing_key.pem ${KERNEL_DIR}/certs/signing_key.x509 ${TARGET_DIR}/hailo_pci.ko
    echo -e "\e[32mModule signed.\e[0m"
}

function build_sequence {
    prepare
    build
    mv_file
    signing_module
    echo ""
    echo -e "\e[32mDriver build completed.\e[0m"
    echo -e "\e[32mModule located at ${TARGET_DIR}/hailo_pci.ko\e[0m"
}

function clean {
    echo "Cleaning up module artifacts"
    clean_dirs=(
        "${PCIE_DRIVER_ROOT}"
        "${PCIE_DRIVER_ROOT}/src"
        "${PCIE_DRIVER_ROOT}/.tmp_versions"
        "${PCIE_DRIVER_ROOT}/build"
        "${PROJECT_ROOT}/common"
        "${PROJECT_ROOT}/vdma"
        "${PROJECT_ROOT}/linux"
    )
    patterns=("*.o" "*.o.cmd" "*.mod.c" "*.mod.o")
    for dir in "${clean_dirs[@]}"; do
        if [ -d "$dir" ]; then
            for pattern in "${patterns[@]}"; do
                find "$dir" -type f -name "$pattern" -print -delete || true
            done
        fi
    done

    echo ""
    echo -e "\e[32mClean up completed.\e[0m"
}

if [ $# -eq 0 ]; then
    build_sequence
else
    case $1 in
        -c)
            clean
            ;;
        -b)
            build_sequence
            ;;
        *)
            echo "Invalid option. Use -b to build or -c to clean."
            exit 1
            ;;
    esac
fi
