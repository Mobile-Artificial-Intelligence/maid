#!/bin/bash

set -e

APP_NAME="maid"
APP_DIR="build/macos/Build/Products/Release/${APP_NAME}.app"
DMG_DIR="dmg"
TMP_MOUNT="/tmp/Maid"
DMG_BACKGROUND_IMG="./media/feature.png"
WINX=0
WINY=0
WINW=750
WINH=400
ICON_SIZE=64
TEXT_SIZE=14

# Create the dmg and app directories if they do not exist
mkdir -p ${DMG_DIR}
mkdir -p ${TMP_MOUNT}

# Create temporary DMG
hdiutil create ${DMG_DIR}/${APP_NAME}_tmp.dmg -volname "${APP_NAME}" -srcfolder "${APP_DIR}" -ov -format UDRW

# Mount the temporary DMG
hdiutil attach ${DMG_DIR}/${APP_NAME}_tmp.dmg -mountpoint ${TMP_MOUNT}

# Copy background image
mkdir -p ${TMP_MOUNT}/.background
cp ${DMG_BACKGROUND_IMG} ${TMP_MOUNT}/.background/feature.png

# Create a symbolic link to the Applications folder
ln -s /Applications ${TMP_MOUNT}/Applications

# AppleScript to set DMG properties
osascript <<EOF
on run
    tell application "Finder"
        tell disk "${APP_NAME}"
            open

            set dsStore to "\"" & "/Volumes/${APP_NAME}/.DS_Store\""

            tell container window
                set current view to icon view
                set toolbar visible to false
                set statusbar visible to false
                set the bounds to {${WINX}, ${WINY}, ${WINW}, ${WINH}}
                set statusbar visible to false
            end tell

            set opts to the icon view options of container window
            tell opts
                set icon size to ${ICON_SIZE}
                set text size to ${TEXT_SIZE}
                set arrangement to not arranged
            end tell
            set background picture of opts to file ".background:feature.png"

            -- Positioning
            set position of item "${APP_NAME}.app" of container window to {450, 200}
            set position of item "Applications" of container window to {650, 200}

            close
            open
            -- Force saving of the size
            delay 1

            tell container window
                set statusbar visible to false
                set the bounds to {${WINX}, ${WINY}, ${WINW}, ${WINH}}
            end tell
        end tell

        delay 1

        tell disk "${APP_NAME}"
            tell container window
                set statusbar visible to false
                set the bounds to {${WINX}, ${WINY}, ${WINW}, ${WINH}}
            end tell
        end tell

        --give the finder some time to write the .DS_Store file
        delay 3

        set waitTime to 0
        set ejectMe to false
        repeat while ejectMe is false
            delay 1
            set waitTime to waitTime + 1
            
            if (do shell script "[ -f " & dsStore & " ]; echo $?") = "0" then set ejectMe to true
        end repeat
        log "waited " & waitTime & " seconds for .DS_Store to be created."
    end tell
end run
EOF

# Unmount the temporary DMG
hdiutil detach ${TMP_MOUNT}

# Convert to final DMG
hdiutil convert ${DMG_DIR}/${APP_NAME}_tmp.dmg -format UDZO -o ${DMG_DIR}/${APP_NAME}.dmg

# Remove temporary DMG
rm ${DMG_DIR}/${APP_NAME}_tmp.dmg

echo "DMG creation completed successfully!"
