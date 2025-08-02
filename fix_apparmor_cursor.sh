#!/bin/bash

echo "=== Fixing AppArmor Issues for Cursor ==="
echo ""

# Load environment variables
if [ -f ".env" ]; then
    echo "Loading configuration from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "No .env file found, using default path..."
    CURSOR_APPIMAGE_PATH="/path/to/your/Cursor-AppImage.AppImage"
fi

# Validate the AppImage path
if [ ! -f "$CURSOR_APPIMAGE_PATH" ]; then
    echo "Error: Cursor AppImage not found at $CURSOR_APPIMAGE_PATH"
    echo "Please create a .env file with your CURSOR_APPIMAGE_PATH"
    exit 1
fi

# Create wrapper script that bypasses AppArmor
echo "1. Creating wrapper script..."
sudo tee /usr/local/bin/cursor-wrapper > /dev/null << EOF
#!/bin/bash
# Wrapper script to run Cursor with AppArmor considerations

# Always run with --no-sandbox to avoid AppArmor issues
exec "$CURSOR_APPIMAGE_PATH" --no-sandbox "\$@"
EOF

sudo chmod +x /usr/local/bin/cursor-wrapper

# Update the desktop entry to use the wrapper
echo "2. Updating desktop entry..."
sudo sed -i 's|Exec=.*AppImage %F|Exec=/usr/local/bin/cursor-wrapper %F|' /usr/share/applications/cursor.desktop

# Update the symlink
echo "3. Updating symlink..."
sudo ln -sf /usr/local/bin/cursor-wrapper /usr/local/bin/cursor

# Update desktop database
echo "4. Updating desktop database..."
sudo update-desktop-database

echo ""
echo "=== AppArmor Fix Complete ==="
echo "Cursor should now work with AppArmor enabled."
echo "The --no-sandbox flag bypasses AppArmor restrictions."
echo ""
echo "Configuration used:"
echo "  AppImage: $CURSOR_APPIMAGE_PATH" 