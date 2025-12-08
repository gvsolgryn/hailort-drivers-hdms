#!/bin/bash
set -e

readonly BASE_URI="https://hailo-hailort.s3.eu-west-2.amazonaws.com"
readonly HRT_VERSION=4.22.0
readonly FW_AWS_DIR="Hailo8/${HRT_VERSION}/FW"
readonly FW="hailo8_fw.${HRT_VERSION}.bin"
readonly FW_REMOTE="hailo8_fw.${HRT_VERSION}.bin"
readonly OUT_DIR="$(cd "$(dirname "$0")" && pwd)/out"
readonly OUT_FNAME="${OUT_DIR}/hailo8_fw.bin"
readonly TMP_DL="$(mktemp /tmp/hailo-fw.XXXXXX)"

function info() {
    echo "[INFPO] $*";
}

function error() {
    echo "[ERROR] $*" >&2;
}

# 1) Check if firmware already exists
if [ -s "${OUT_FNAME}" ]; then
    info "Firmware already exists at ${OUT_FNAME}, skipping download"
    exit 0
fi

# 2) Check if firmware is in working dir
if [ -s "./${FW_REMOTE}" ]; then
    info "Found existing ${FW_REMOTE} in working dir — moving to ${OUT_FNAME}."
    mkdir -p "${OUT_DIR}"
    mv "./${FW_REMOTE}" "${OUT_FNAME}"
    chmod 0644 "${OUT_FNAME}"
    info "Moved and ready: ${OUT_FNAME}"
    exit 0
fi

# 3) Download firmware
function download_fw(){
    local url="${BASE_URI}/${FW_AWS_DIR}/${FW_REMOTE}"
    info "Downloading ${url} -> ${TMP_DL}"
    if command -v curl >/dev/null 2>&1; then
        curl -fSL --retry 3 -o "${TMP_DL}" "${url}"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "${TMP_DL}" --tries=3 --timeout=30 "${url}"
    else
        err "curl or wget required to download firmware"
        rm -f "${TMP_DL}"
        exit 2
    fi

    # checksum verification can be added here if needed
    if [ ! -s "${TMP_DL}" ]; then
        err "Downloaded file is empty"
        rm -f "${TMP_DL}"
        exit 3
    fi

    mkdir -p "${OUT_DIR}"
    mv "${TMP_DL}" "${OUT_FNAME}"
    chmod 0644 "${OUT_FNAME}"
    info "Downloaded and placed firmware at ${OUT_FNAME}"
}

download_fw

