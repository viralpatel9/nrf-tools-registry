#!/usr/bin/env bash
set -e

echo "===== Programming Tools Setup Script ====="

# -------------------------
# OS CHECK
# -------------------------
if [[ "$(uname -s)" != "Linux" ]]; then
    echo "ERROR: Linux only."
    exit 1
fi

ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

# -------------------------
# INSTALL BASE PACKAGES
# -------------------------
echo "Updating package lists..."
apt-get update -y

echo "Installing base dependencies..."
apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    ca-certificates \
    unzip \
    python3-venv \
    python3-pip \
    udev \
    libusb-1.0-0-dev \
    libudev-dev \
    libglib2.0-dev \
    libdbus-1-dev \

# -------------------------
# INSTALL PYTHON
# -------------------------
if ! command -v python3 >/dev/null 2>&1; then
    echo "Installing Python..."
    apt-get install -y python3 python3-pip python3-venv
else
    echo "Python already installed"
fi

# ensure pip is latest
python3 -m pip install --upgrade pip setuptools wheel

# -------------------------
# INSTALL OPENOCD
# -------------------------
if ! command -v openocd >/dev/null 2>&1; then
    echo "Installing OpenOCD..."
    apt-get install -y openocd
else
    echo "OpenOCD already installed"
fi

# -------------------------
# INSTALL JLINK
# -------------------------
if command -v JLinkExe >/dev/null 2>&1; then
    echo "JLink already installed"
else
    echo "Installing JLink..."

    TMPDIR=$(mktemp -d)
    cd "$TMPDIR"

    # Change version here when needed
    JLINK_VERSION="V794g"

    case "$ARCH" in
        x86_64|amd64)
            FILE="JLink_Linux_${JLINK_VERSION}_x86_64.deb"
            ;;
        aarch64|arm64)
            FILE="JLink_Linux_${JLINK_VERSION}_arm64.deb"
            ;;
        armv7l|armhf)
            FILE="JLink_Linux_${JLINK_VERSION}_armhf.deb"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    URL="https://www.segger.com/downloads/jlink/$FILE"

    echo "Downloading $FILE"
    wget -q --show-progress --post-data "accept_license_agreement=accepted" "$URL"

    echo "Installing package (udev-safe mode)..."

    # prevent postinst from failing when udev isn't present (containers/CI)
    for udevadm_path in /usr/local/bin/udevadm /usr/bin/udevadm /sbin/udevadm; do
        if [ ! -e "$udevadm_path" ]; then
            ln -sf /bin/true "$udevadm_path"
        fi
    done

    dpkg -i "$FILE" || apt-get install -f -y

    # Remove fake udevadm symlinks
    for udevadm_path in /usr/local/bin/udevadm /usr/bin/udevadm /sbin/udevadm; do
        if [ -L "$udevadm_path" ] && [ "$(readlink "$udevadm_path")" = "/bin/true" ]; then
            rm -f "$udevadm_path"
        fi
    done

    cd /
    rm -rf "$TMPDIR"
fi

# -------------------------
# INSTALL nrfjprog
# -------------------------
if ! command -v nrfjprog >/dev/null 2>&1; then
    echo "Installing nrfjprog..."

    TEMPDIR=$(mktemp -d)
    cd "$TEMPDIR"

    # Change version here when needed
    case "$ARCH" in
        x86_64|amd64)
            FILE="nrf-command-line-tools_10.24.2_amd64.deb"
            ;;
        aarch64|arm64)
            FILE="nrf-command-line-tools_10.24.2_arm64.deb"
            ;;
        armv7l|armhf)
            FILE="nrf-command-line-tools_10.24.2_armhf.deb"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    URL="https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-24-2/$FILE"

    echo "Downloading $FILE"
    wget -q --show-progress "$URL"

    echo "Installing package..."
    dpkg -i "$FILE" || apt-get install -f -y

    cd /
    rm -rf "$TEMPDIR"
else
    echo "nrfjprog already installed"
fi


# -------------------------
# Install nrfutil
# -------------------------
if ! command -v nrfutil >/dev/null 2>&1; then
    echo "Installing nrfutil..."

    TEMPDIR=$(mktemp -d)
    cd "$TEMPDIR"

    # Change version here when needed
    case "$ARCH" in
        x86_64|amd64)
            URL="https://files.nordicsemi.com/artifactory/swtools/external/nrfutil/executables/x86_64-unknown-linux-gnu/nrfutil"
            ;;
        aarch64|arm64)
            URL="https://files.nordicsemi.com/artifactory/swtools/external/nrfutil/executables/aarch64-unknown-linux-gnu/nrfutil"
            ;;
        armv7l|armhf)
            URL="https://files.nordicsemi.com/artifactory/swtools/external/nrfutil/executables/armv7l-unknown-linux-gnueabihf/nrfutil"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    echo "Downloading nrfutil from $URL"
    curl "$URL" -o nrfutil

    echo "Installing nrfutil..."
    chmod +x nrfutil
    mv nrfutil /usr/local/bin/
    cd /
    rm -rf "$TEMPDIR"

else
    echo "nrfutil already installed"
fi


# -------------------------
# VERIFY INSTALLATION
# -------------------------
echo
echo "Verification:"
command -v python3 && echo "Python OK"
command -v pip3 && echo "pip OK"
command -v openocd && echo "OpenOCD OK"
command -v JLinkExe && echo "JLink OK"
command -v nrfjprog && echo "nrfjprog OK"
command -v nrfutil && echo "nrfutil OK"

echo
echo "Setup complete."
