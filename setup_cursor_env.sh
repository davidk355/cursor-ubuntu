#!/bin/bash

# Cursor Desktop Integration with Environment Variables
# This script reads configuration from .env file or environment variables

set -e

# Function to load environment variables
load_env() {
    if [ -f ".env" ]; then
        echo "Loading configuration from .env file..."
        export $(cat .env | grep -v '^#' | xargs)
    else
        echo "No .env file found, using default values..."
    fi
}

# Function to get configuration with defaults
get_config() {
    # Load environment variables
    load_env
    
    # Set defaults if not provided
    export USERNAME=${USERNAME:-$(whoami)}
    export APPLICATIONS_DIR=${APPLICATIONS_DIR:-"/home/$USERNAME/Applications"}
    
    # Validate required variables
    if [ -z "$CURSOR_APPIMAGE_PATH" ]; then
        echo "Error: CURSOR_APPIMAGE_PATH is not set"
        echo "Please create a .env file with your Cursor AppImage path"
        echo "Example:"
        echo "CURSOR_APPIMAGE_PATH=/home/$USERNAME/Applications/Cursor-AppImage.AppImage"
        exit 1
    fi
    
    # Validate that the AppImage exists
    if [ ! -f "$CURSOR_APPIMAGE_PATH" ]; then
        echo "Error: Cursor AppImage not found at $CURSOR_APPIMAGE_PATH"
        echo "Please check your CURSOR_APPIMAGE_PATH in .env file"
        exit 1
    fi
    
    echo "Configuration loaded:"
    echo "  Username: $USERNAME"
    echo "  Applications Directory: $APPLICATIONS_DIR"
    echo "  Cursor AppImage: $CURSOR_APPIMAGE_PATH"
    echo ""
}

# Function to create desktop entry with environment variables
create_desktop_entry() {
    local temp_dir=$(mktemp -d)
    echo "Extracting AppImage to find icon..."
    
    cd "$temp_dir"
    "$CURSOR_APPIMAGE_PATH" --appimage-extract > /dev/null 2>&1
    
    # Look for the cursor icon
    ICON_PATH=""
    if [ -f "squashfs-root/usr/share/icons/hicolor/256x256/apps/cursor.png" ]; then
        ICON_PATH="squashfs-root/usr/share/icons/hicolor/256x256/apps/cursor.png"
    elif [ -f "squashfs-root/usr/share/icons/hicolor/128x128/apps/cursor.png" ]; then
        ICON_PATH="squashfs-root/usr/share/icons/hicolor/128x128/apps/cursor.png"
    elif [ -f "squashfs-root/usr/share/icons/hicolor/64x64/apps/cursor.png" ]; then
        ICON_PATH="squashfs-root/usr/share/icons/hicolor/64x64/apps/cursor.png"
    elif [ -f "squashfs-root/co.anysphere.cursor.png" ]; then
        ICON_PATH="squashfs-root/co.anysphere.cursor.png"
    fi
    
    if [ -n "$ICON_PATH" ]; then
        sudo cp "$ICON_PATH" /usr/share/pixmaps/cursor.png
        ICON_PATH="/usr/share/pixmaps/cursor.png"
    else
        ICON_PATH="text-editor"
    fi
    
    cd /
    rm -rf "$temp_dir"
    
    # Create wrapper script
    sudo tee /usr/local/bin/cursor-wrapper > /dev/null << EOF
#!/bin/bash
# Wrapper script to run Cursor with AppArmor considerations

# Always run with --no-sandbox to avoid AppArmor issues
exec "$CURSOR_APPIMAGE_PATH" --no-sandbox "\$@"
EOF
    
    sudo chmod +x /usr/local/bin/cursor-wrapper
    
    # Create desktop entry
    cat > /tmp/cursor.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Cursor
GenericName=Code Editor
Comment=AI-first code editor
Exec=/usr/local/bin/cursor-wrapper %F
Icon=$ICON_PATH
Terminal=false
Categories=Development;IDE;TextEditor;
Keywords=editor;code;development;IDE;cursor;
StartupWMClass=Cursor
MimeType=text/plain;inode/directory;application/x-code-workspace;
EOF
    
    sudo cp /tmp/cursor.desktop /usr/share/applications/
    sudo chmod +x /usr/share/applications/cursor.desktop
    
    # Create symlink
    sudo ln -sf /usr/local/bin/cursor-wrapper /usr/local/bin/cursor
    
    # Update desktop database
    sudo update-desktop-database
}

# Function to install MIME associations
install_mime_associations() {
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
    
    sudo update-mime-database /usr/share/mime
}

# Main installation function
install_cursor() {
    echo "=== Cursor Desktop Integration with Environment Variables ==="
    echo ""
    
    # Load configuration
    get_config
    
    echo "Installing Cursor desktop integration..."
    
    # Create desktop entry
    create_desktop_entry
    
    # Install MIME associations
    install_mime_associations
    
    echo ""
    echo "=== Installation Complete ==="
    echo "Cursor should now appear in your applications menu."
    echo ""
    echo "Configuration used:"
    echo "  AppImage: $CURSOR_APPIMAGE_PATH"
    echo "  Username: $USERNAME"
    echo "  Applications Dir: $APPLICATIONS_DIR"
}

# Function to uninstall
uninstall_cursor() {
    echo "=== Uninstalling Cursor Desktop Integration ==="
    echo ""
    
    # Remove desktop entry
    if [ -f "/usr/share/applications/cursor.desktop" ]; then
        sudo rm /usr/share/applications/cursor.desktop
        echo "✓ Desktop entry removed"
    fi
    
    # Remove icon
    if [ -f "/usr/share/pixmaps/cursor.png" ]; then
        sudo rm /usr/share/pixmaps/cursor.png
        echo "✓ Icon removed"
    fi
    
    # Remove wrapper and symlink
    if [ -f "/usr/local/bin/cursor-wrapper" ]; then
        sudo rm /usr/local/bin/cursor-wrapper
        echo "✓ Wrapper script removed"
    fi
    
    if [ -L "/usr/local/bin/cursor" ]; then
        sudo rm /usr/local/bin/cursor
        echo "✓ Symlink removed"
    fi
    
    # Remove MIME associations
    if [ -f "/usr/share/mime/packages/cursor-workspace.xml" ]; then
        sudo rm /usr/share/mime/packages/cursor-workspace.xml
        sudo update-mime-database /usr/share/mime
        echo "✓ MIME associations removed"
    fi
    
    # Update desktop database
    sudo update-desktop-database
    
    echo ""
    echo "=== Uninstall Complete ==="
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [install|uninstall|config]"
    echo ""
    echo "Commands:"
    echo "  install   - Install Cursor desktop integration"
    echo "  uninstall - Remove Cursor desktop integration"
    echo "  config    - Show current configuration"
    echo ""
    echo "Environment Variables:"
    echo "  CURSOR_APPIMAGE_PATH - Path to your Cursor AppImage"
    echo "  USERNAME             - Your username (auto-detected if not set)"
    echo "  APPLICATIONS_DIR     - Applications directory (auto-detected if not set)"
    echo ""
    echo "Example .env file:"
    echo "  CURSOR_APPIMAGE_PATH=/home/username/Applications/Cursor-AppImage.AppImage"
    echo "  USERNAME=username"
    echo "  APPLICATIONS_DIR=/home/username/Applications"
}

# Main script logic
case "${1:-install}" in
    install)
        install_cursor
        ;;
    uninstall)
        uninstall_cursor
        ;;
    config)
        get_config
        ;;
    *)
        show_usage
        exit 1
        ;;
esac 