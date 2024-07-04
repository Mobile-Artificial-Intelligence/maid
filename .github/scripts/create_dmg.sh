#!/bin/bash

set -e

APP_NAME="maid"
APP_DIR="build/macos/Build/Products/Release/${APP_NAME}.app"
DMG_TEMPLATE="./.github/assets/maid.dmg"
DMG_OUTPUT="./dmg/${APP_NAME}.dmg"
TMP_MOUNT="/tmp/Maid"

# Create the dmg directory if it does not exist
mkdir -p "$(dirname ${DMG_OUTPUT})"
mkdir -p ${TMP_MOUNT}

# Mount the template DMG
hdiutil attach ${DMG_TEMPLATE} -mountpoint ${TMP_MOUNT} -nobrowse -noverify -noautoopen

# Replace the TARGET file with maid.app
rm -rf "${TMP_MOUNT}/TARGET"
cp -R "${APP_DIR}" "${TMP_MOUNT}/maid.app"

# Unmount the template DMG
hdiutil detach ${TMP_MOUNT}

# Create the final DMG from the modified template
hdiutil convert ${DMG_TEMPLATE} -format UDZO -o ${DMG_OUTPUT}

echo "DMG creation completed successfully!"
