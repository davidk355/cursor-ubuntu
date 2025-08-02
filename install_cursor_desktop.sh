#!/bin/bash

# Script to install Cursor desktop entry
# This script will make Cursor appear in the Ubuntu applications menu

echo "Installing Cursor desktop entry..."

# Check if Cursor AppImage exists in the specified location
CURSOR_APPIMAGE="/path/to/your/Cursor-AppImage.AppImage"
if [ ! -f "$CURSOR_APPIMAGE" ]; then
    echo "Error: Cursor AppImage not found at $CURSOR_APPIMAGE"
    echo "Please update the CURSOR_APPIMAGE variable in this script with your actual path"
    exit 1
fi

# Create a temporary directory for extraction
TEMP_DIR=$(mktemp -d)
echo "Extracting AppImage to find icon..."

# Extract the AppImage to find the icon
cd "$TEMP_DIR"
"$CURSOR_APPIMAGE" --appimage-extract > /dev/null 2>&1

# Look for the cursor icon in the extracted files
ICON_PATH=""
if [ -f "squashfs-root/usr/share/icons/hicolor/256x256/apps/cursor.png" ]; then
    ICON_PATH="squashfs-root/usr/share/icons/hicolor/256x256/apps/cursor.png"
elif [ -f "squashfs-root/usr/share/icons/hicolor/128x128/apps/cursor.png" ]; then
    ICON_PATH="squashfs-root/usr/share/icons/hicolor/128x128/apps/cursor.png"
elif [ -f "squashfs-root/usr/share/icons/hicolor/64x64/apps/cursor.png" ]; then
    ICON_PATH="squashfs-root/usr/share/icons/hicolor/64x64/apps/cursor.png"
elif [ -f "squashfs-root/usr/share/icons/hicolor/48x48/apps/cursor.png" ]; then
    ICON_PATH="squashfs-root/usr/share/icons/hicolor/48x48/apps/cursor.png"
elif [ -f "squashfs-root/co.anysphere.cursor.png" ]; then
    ICON_PATH="squashfs-root/co.anysphere.cursor.png"
fi

if [ -z "$ICON_PATH" ]; then
    echo "Warning: Could not find cursor icon in AppImage"
    echo "Using generic text editor icon"
    ICON_PATH="text-editor"
else
    echo "Found icon: $ICON_PATH"
    # Copy the icon to a system location
    sudo cp "$ICON_PATH" /usr/share/pixmaps/cursor.png
    ICON_PATH="/usr/share/pixmaps/cursor.png"
fi

# Create the desktop entry file
cat > cursor.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Cursor
Comment=AI-first code editor
Exec=$CURSOR_APPIMAGE
Icon=$ICON_PATH
Terminal=false
Categories=Development;IDE;TextEditor;
Keywords=editor;code;development;IDE;
StartupWMClass=Cursor
EOF

# Copy the desktop entry to the system applications directory
sudo cp cursor.desktop /usr/share/applications/

# Make the desktop entry executable
sudo chmod +x /usr/share/applications/cursor.desktop

# Update the desktop database
sudo update-desktop-database

# Clean up temporary files
cd /
rm -rf "$TEMP_DIR"

echo "Cursor desktop entry installed successfully!"
echo "You should now be able to find Cursor in your applications menu."
echo "If you don't see it immediately, try logging out and back in, or restart your desktop environment." 