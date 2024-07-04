#!/bin/bash

set -e

APP_NAME="maid"
APP_DIR="build/macos/Build/Products/Release/${APP_NAME}.app"
DMG_DIR="dmg"
TMP_MOUNT="/tmp/Maid"
DMG_BACKGROUND_IMG="./media/feature.png"

# Create the dmg and app directories if they do not exist
mkdir -p ${DMG_DIR}
mkdir -p ${TMP_MOUNT}

# Create temporary DMG
hdiutil create ${DMG_DIR}/${APP_NAME}_tmp.dmg -volname "${APP_NAME}" -srcfolder "${APP_DIR}" -ov -format UDRW

# Mount the temporary DMG
hdiutil attach ${DMG_DIR}/${APP_NAME}_tmp.dmg -mountpoint ${TMP_MOUNT}

# Copy background image
mkdir ${TMP_MOUNT}/.background
cp ${DMG_BACKGROUND_IMG} ${TMP_MOUNT}/.background/feature.png

# Create a symbolic link to the Applications folder
ln -s /Applications ${TMP_MOUNT}/Applications

# Set the background image
osascript <<EOF
tell application "Finder"
  tell disk "${APP_NAME}"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {0, 0, 1024, 500}
    set viewOptions to the icon view options of container window
    set arrangement of viewOptions to not arranged
    set icon size of viewOptions to 128
    set background picture of viewOptions to file ".background:feature.png"
    set position of item "${APP_NAME}.app" of container window to {200, 300}
    set position of item "Applications" of container window to {800, 300}
    close
    open
    update without registering applications
    delay 5
  end tell
end tell
EOF

# Unmount the temporary DMG
hdiutil detach ${TMP_MOUNT}

# Convert to final DMG
hdiutil convert ${DMG_DIR}/${APP_NAME}_tmp.dmg -format UDZO -o ${DMG_DIR}/${APP_NAME}.dmg

# Remove temporary DMG
rm ${DMG_DIR}/${APP_NAME}_tmp.dmg
