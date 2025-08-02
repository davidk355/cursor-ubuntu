#!/bin/bash

echo "=== Cursor Desktop Integration Environment Setup ==="
echo "This script will help you create a .env file with your configuration."
echo ""

# Check if .env already exists
if [ -f ".env" ]; then
    echo "Warning: .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

# Get current username
CURRENT_USER=$(whoami)
echo "Current username: $CURRENT_USER"

# Get Cursor AppImage path
echo ""
echo "Please provide the path to your Cursor AppImage:"
echo "Example: /home/$CURRENT_USER/Applications/Cursor-AppImage.AppImage"

# Try to auto-detect common locations
DEFAULT_PATHS=(
    "/home/$CURRENT_USER/Applications/Cursor*.AppImage"
    "/home/$CURRENT_USER/Applications/Cursor*.AppImage"
    "/home/$CURRENT_USER/Downloads/Cursor*.AppImage"
    "/opt/Cursor*.AppImage"
)

echo ""
echo "Checking common locations..."

for path in "${DEFAULT_PATHS[@]}"; do
    if ls $path >/dev/null 2>&1; then
        FOUND_PATH=$(ls $path | head -1)
        echo "Found: $FOUND_PATH"
        read -p "Use this path? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            CURSOR_PATH="$FOUND_PATH"
            break
        fi
    fi
done

# If no path was selected, ask for manual input
if [ -z "$CURSOR_PATH" ]; then
    read -p "Enter the full path to your Cursor AppImage: " CURSOR_PATH
fi

# Validate the path
if [ ! -f "$CURSOR_PATH" ]; then
    echo "Error: File not found at $CURSOR_PATH"
    exit 1
fi

# Get applications directory
echo ""
echo "Applications directory (default: /home/$CURRENT_USER/Applications):"
read -p "Enter applications directory path: " APPLICATIONS_DIR
APPLICATIONS_DIR=${APPLICATIONS_DIR:-"/home/$CURRENT_USER/Applications"}

# Create .env file
echo ""
echo "Creating .env file..."
cat > .env << EOF
# Cursor Desktop Integration Environment Variables
# This file contains your personal configuration

# Path to your Cursor AppImage
CURSOR_APPIMAGE_PATH=$CURSOR_PATH

# Your username (optional, will be auto-detected if not set)
USERNAME=$CURRENT_USER

# Applications directory (optional, defaults to /home/USERNAME/Applications)
APPLICATIONS_DIR=$APPLICATIONS_DIR
EOF

echo "✓ .env file created successfully!"
echo ""
echo "Configuration:"
echo "  AppImage: $CURSOR_PATH"
echo "  Username: $CURRENT_USER"
echo "  Applications Dir: $APPLICATIONS_DIR"
echo ""
echo "You can now run: ./setup_cursor_env.sh install" 