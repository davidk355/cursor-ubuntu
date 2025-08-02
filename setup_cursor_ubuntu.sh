#!/bin/bash

# Comprehensive Cursor setup script for Ubuntu 24
# This script handles all aspects of Cursor integration

set -e  # Exit on any error

echo "=== Cursor Ubuntu 24 Setup Script ==="
echo "This script will set up Cursor with proper desktop integration"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Error: Please don't run this script as root"
    exit 1
fi

# Check Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)
echo "Detected Ubuntu version: $UBUNTU_VERSION"

# Check if AppImage is executable
CURSOR_APPIMAGE="/path/to/your/Cursor-AppImage.AppImage"
if [ ! -f "$CURSOR_APPIMAGE" ]; then
    echo "Error: Cursor AppImage not found at $CURSOR_APPIMAGE"
    echo "Please update the CURSOR_APPIMAGE variable in this script with your actual path"
    exit 1
fi

# Make AppImage executable if it isn't already
if [ ! -x "$CURSOR_APPIMAGE" ]; then
    echo "Making AppImage executable..."
    chmod +x "$CURSOR_APPIMAGE"
fi

# Check if AppImage is properly formatted
echo "Verifying AppImage integrity..."
if ! "$CURSOR_APPIMAGE" --appimage-version > /dev/null 2>&1; then
    echo "Warning: AppImage may be corrupted or not properly formatted"
    echo "Attempting to fix permissions..."
    chmod +x "$CURSOR_APPIMAGE"
fi

# Create Applications directory if it doesn't exist
if [ ! -d "/home/$(whoami)/Applications" ]; then
    echo "Creating Applications directory..."
    mkdir -p /home/$(whoami)/Applications
fi

# Install desktop entry
echo ""
echo "=== Installing Desktop Entry ==="

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
    echo "Found 256x256 icon"
elif [ -f "squashfs-root/usr/share/icons/hicolor/128x128/apps/cursor.png" ]; then
    ICON_PATH="squashfs-root/usr/share/icons/hicolor/128x128/apps/cursor.png"
    echo "Found 128x128 icon"
elif [ -f "squashfs-root/usr/share/icons/hicolor/64x64/apps/cursor.png" ]; then
    ICON_PATH="squashfs-root/usr/share/icons/hicolor/64x64/apps/cursor.png"
    echo "Found 64x64 icon"
elif [ -f "squashfs-root/usr/share/icons/hicolor/48x48/apps/cursor.png" ]; then
    ICON_PATH="squashfs-root/usr/share/icons/hicolor/48x48/apps/cursor.png"
    echo "Found 48x48 icon"
elif [ -f "squashfs-root/co.anysphere.cursor.png" ]; then
    ICON_PATH="squashfs-root/co.anysphere.cursor.png"
    echo "Found main cursor icon"
fi

if [ -z "$ICON_PATH" ]; then
    echo "Warning: Could not find cursor icon in AppImage"
    echo "Using generic text editor icon"
    ICON_PATH="text-editor"
else
    echo "Copying icon to system location..."
    sudo cp "$ICON_PATH" /usr/share/pixmaps/cursor.png
    ICON_PATH="/usr/share/pixmaps/cursor.png"
fi

# Create the desktop entry file
echo "Creating desktop entry..."
cat > cursor.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Cursor
GenericName=Code Editor
Comment=AI-first code editor
Exec=$CURSOR_APPIMAGE %F
Icon=$ICON_PATH
Terminal=false
Categories=Development;IDE;TextEditor;
Keywords=editor;code;development;IDE;cursor;
StartupWMClass=Cursor
MimeType=text/plain;inode/directory;application/x-code-workspace;
EOF

# Copy the desktop entry to the system applications directory
echo "Installing desktop entry..."
sudo cp cursor.desktop /usr/share/applications/

# Make the desktop entry executable
sudo chmod +x /usr/share/applications/cursor.desktop

# Update the desktop database
echo "Updating desktop database..."
sudo update-desktop-database

# Clean up temporary files
cd /
rm -rf "$TEMP_DIR"

# Set up file associations
echo ""
echo "=== Setting up File Associations ==="

# Create MIME type for Cursor workspace files
sudo tee /usr/share/mime/packages/cursor-workspace.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-cursor-workspace">
    <comment>Cursor Workspace</comment>
    <glob pattern="*.cursor-workspace"/>
    <glob pattern="*.cursor"/>
  </mime-type>
</mime-info>
EOF

# Update MIME database
sudo update-mime-database /usr/share/mime

# Set up shell integration (optional)
echo ""
echo "=== Setting up Shell Integration ==="

# Check if shell integration is available in the AppImage
if [ -f "/tmp/cursor-extract/squashfs-root/usr/share/cursor/resources/completions/bash/cursor" ]; then
    echo "Shell integration found. To enable it, add this to your ~/.bashrc:"
    echo "source /usr/share/cursor/resources/completions/bash/cursor"
fi

# Create a symlink for easier access (optional)
echo ""
echo "=== Creating Symlink ==="
if [ ! -L "/usr/local/bin/cursor" ]; then
    echo "Creating symlink for 'cursor' command..."
    sudo ln -sf "$CURSOR_APPIMAGE" /usr/local/bin/cursor
    echo "You can now run 'cursor' from anywhere"
else
    echo "Symlink already exists"
fi

# Test the installation
echo ""
echo "=== Testing Installation ==="
if [ -f "/usr/share/applications/cursor.desktop" ]; then
    echo "✓ Desktop entry installed successfully"
else
    echo "✗ Desktop entry installation failed"
fi

if [ -f "/usr/share/pixmaps/cursor.png" ] || [ "$ICON_PATH" = "text-editor" ]; then
    echo "✓ Icon configured successfully"
else
    echo "✗ Icon configuration failed"
fi

echo ""
echo "=== Setup Complete ==="
echo "Cursor should now appear in your applications menu."
echo ""
echo "Troubleshooting tips:"
echo "1. If Cursor doesn't appear immediately, try logging out and back in"
echo "2. You can also restart your desktop environment:"
echo "   - GNOME: Alt+F2, type 'r', press Enter"
echo "   - Or restart your session"
echo ""
echo "3. To test the installation, run:"
echo "   $CURSOR_APPIMAGE"
echo ""
echo "4. If you want to remove the installation, run:"
echo "   ./uninstall_cursor_desktop.sh"
echo ""
echo "5. For shell completion, add to your ~/.bashrc:"
echo "   source /usr/share/cursor/resources/completions/bash/cursor" 