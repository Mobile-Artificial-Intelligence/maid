#!/bin/bash

set -e

APP_NAME="maid"
BUILD_DIR="maid-linux"
APPIMAGE_DIR="AppDir"
APPICON="assets/maid.png"

# Create the AppDir directory if it does not exist
mkdir -p ${APPIMAGE_DIR}

# Copy the application files
cp -r ${BUILD_DIR}/* ${APPIMAGE_DIR}/
cp ${APPICON} ${APPIMAGE_DIR}/icon.png

# Create the desktop entry
cat > ${APPIMAGE_DIR}/${APP_NAME}.desktop <<EOF
[Desktop Entry]
Name=Maid
Exec=${APP_NAME}
Icon=icon
Type=Application
Categories=Utility;
EOF

# Make the main executable and AppRun script executable
chmod +x ${APPIMAGE_DIR}/${APP_NAME}
cat > ${APPIMAGE_DIR}/AppRun <<EOF
#!/bin/bash
HERE="$(dirname "$(readlink -f "\${0}")")"
exec "\$HERE/${APP_NAME}" "\$@"
EOF
chmod +x ${APPIMAGE_DIR}/AppRun

# Create the AppImage
appimagetool ${APPIMAGE_DIR} ${APP_NAME}.AppImage