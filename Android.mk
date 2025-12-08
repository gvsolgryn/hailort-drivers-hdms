LOCAL_PATH := $(call my-dir)

# $(shell [-s $(LOCAL_PATH)/out/hailo8_fw.bin] || bash $(LOCAL_PATH)/download_firmware.sh)
# $(shell mkdir -p $(TARGET_OUT_VENDOR)/firmware_mnt/image/hailo 2>/dev/null || true)
# $(shell if [ ! -s $(LOCAL_PATH)/out/hailo8_fw.bin ]; then bash $(LOCAL_PATH)/download_firmware.sh; fi)

$(shell mkdir -p $(LOCAL_PATH)/out)

OUT_FW := $(LOCAL_PATH)/out/hailo8_fw.bin
DOWNLOAD_SCRIPT := $(LOCAL_PATH)/download_firmware.sh

$(OUT_FW):
	@echo "[download] generating $(OUT_FW)"
	@if [ -s "$(OUT_FW)" ]; then \
		echo "[download] $(OUT_FW) already exists, skip"; \
	else \
		if [ -x "$(DOWNLOAD_SCRIPT)" ]; then \
			mkdir -p "$(LOCAL_PATH)/out"; \
			bash "$(DOWNLOAD_SCRIPT)"; \
		else \
			echo "ERROR: download script not found or not executable: $(DOWNLOAD_SCRIPT)" >&2; \
			exit 2; \
		fi; \
	fi

.PHONY: download_firmware
download_firmware: $(OUT_FW)

include $(CLEAR_VARS)
LOCAL_MODULE := hailo8_fw.bin
LOCAL_SRC_FILES := out/hailo8_fw.bin
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/firmware/hailo
# LOCAL_MODULE_STEM := hailo8_fw.bin
# LOCAL_CERTIFICATE := PRESIGNED
include $(BUILD_PREBUILT)

include $(LOCAL_PATH)/linux/pcie/Android.mk