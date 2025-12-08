LOCAL_PATH 		:= $(call my-dir)
DLKM_DIR   		:= $(TOP)/device/qcom/common/dlkm

ABS_LOCAL   	:= $(abspath $(LOCAL_PATH))                 # .../hailort-drivers/linux/pcie
HAILO_LINUX 	:= $(abspath $(LOCAL_PATH)/..)              # .../hailort-drivers/linux
HAILO_COMMON	:= $(abspath $(LOCAL_PATH)/../../common)    # .../hailort-drivers/common
HAILO_VDMA  	:= $(abspath $(LOCAL_PATH)/../vdma)         # .../hailort-drivers/linux/vdma
HAILO_UTILS 	:= $(abspath $(LOCAL_PATH)/../utils)        # .../hailort-drivers/linux/utils

HAILO_BUILD_DIR := $(LOCAL_PATH)../../

KBUILD_OPTIONS := HAILO_ROOT=$(HAILO_LINUX)
KBUILD_OPTIONS += KCFLAGS="\
-I$(HAILO_LINUX) \
-I$(HAILO_COMMON) \
-I$(HAILO_VDMA) \
-I$(HAILO_UTILS) "

KBUILD_OPTIONS += BOARD_PLATFORM=$(TARGET_BOARD_PLATFORM)
KBUILD_OPTIONS += CONFIG_HAILO_PCI=m
KBUILD_OPTIONS += V=1

include $(CLEAR_VARS)
LOCAL_MODULE                := hailo_pci.ko
LOCAL_MODULE_KBUILD_NAME    := hailo_pci.ko
LOCAL_MODULE_TAGS           := optional
LOCAL_MODULE_DEBUG_ENABLE   := true
LOCAL_MODULE_PATH           := $(KERNEL_MODULES_OUT)
include $(DLKM_DIR)/AndroidKernelModule.mk
