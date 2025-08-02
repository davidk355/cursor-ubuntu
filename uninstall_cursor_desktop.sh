#!/bin/bash

# Comprehensive script to uninstall Cursor desktop entry

echo "=== Cursor Uninstall Script ==="
echo "This will remove all Cursor desktop integration"
echo ""

# Remove the desktop entry from the system applications directory
if [ -f "/usr/share/applications/cursor.desktop" ]; then
    sudo rm /usr/share/applications/cursor.desktop
    echo "✓ Cursor desktop entry removed"
else
    echo "ℹ Cursor desktop entry not found"
fi

# Remove the icon
if [ -f "/usr/share/pixmaps/cursor.png" ]; then
    sudo rm /usr/share/pixmaps/cursor.png
    echo "✓ Cursor icon removed"
else
    echo "ℹ Cursor icon not found"
fi

# Remove the symlink
if [ -L "/usr/local/bin/cursor" ]; then
    sudo rm /usr/local/bin/cursor
    echo "✓ Cursor symlink removed"
else
    echo "ℹ Cursor symlink not found"
fi

# Remove MIME type associations
if [ -f "/usr/share/mime/packages/cursor-workspace.xml" ]; then
    sudo rm /usr/share/mime/packages/cursor-workspace.xml
    sudo update-mime-database /usr/share/mime
    echo "✓ Cursor MIME associations removed"
else
    echo "ℹ Cursor MIME associations not found"
fi

# Update the desktop database
sudo update-desktop-database

echo ""
echo "=== Uninstall Complete ==="
echo "All Cursor desktop integration has been removed."
echo "Note: The Cursor AppImage itself has not been deleted."
echo "If you want to completely remove Cursor, delete the AppImage file manually." 