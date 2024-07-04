#!/bin/bash

set -e

APP_NAME="maid"
APP_DIR="build/macos/Build/Products/Release/${APP_NAME}.app"
DMG_TEMPLATE="./.github/assets/maid.dmg"
DMG_OUTPUT="./dmg/${APP_NAME}.dmg"
TMP_MOUNT="/tmp/Maid"
TMP_DMG="/tmp/${APP_NAME}_tmp.dmg"
DMG_SIZE=1g

# Create the dmg directory if it does not exist
mkdir -p "$(dirname ${DMG_OUTPUT})"
mkdir -p ${TMP_MOUNT}

# Convert the template DMG to a writable DMG with increased size
hdiutil convert ${DMG_TEMPLATE} -format UDRW -o ${TMP_DMG}
hdiutil resize -size ${DMG_SIZE} ${TMP_DMG}.dmg

# Mount the writable DMG
hdiutil attach ${TMP_DMG}.dmg -mountpoint ${TMP_MOUNT} -nobrowse -noverify -noautoopen

# Replace the TARGET file with maid.app
rm -rf "${TMP_MOUNT}/TARGET"
cp -R "${APP_DIR}" "${TMP_MOUNT}/maid.app"

# Unmount the writable DMG
hdiutil detach ${TMP_MOUNT}

# Convert the writable DMG to a compressed DMG
hdiutil convert ${TMP_DMG}.dmg -format UDZO -o ${DMG_OUTPUT}

# Clean up the temporary writable DMG
rm ${TMP_DMG}.dmg

echo "DMG creation completed successfully!"
