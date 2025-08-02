# Cursor Desktop Integration for Ubuntu 24

This repository contains scripts and files to integrate Cursor into your Ubuntu 24 desktop environment, making it appear in the applications menu with an icon and proper file associations.

## Features

- ✅ **Environment-based configuration** - No hardcoded paths in committed code
- ✅ **Security-focused** - Personal data kept in `.env` file (gitignored)
- ✅ **Portable** - Works across different systems and users
- ✅ **AppArmor compatible** - Handles Ubuntu 24 security restrictions
- ✅ **Complete integration** - Desktop entry, icon, file associations, and terminal command

## Files

- `setup_cursor_env.sh` - **RECOMMENDED**: Environment-based installation script
- `setup_env.sh` - Helper script to create `.env` file
- `env.example` - Example environment configuration
- `cursor.desktop` - Desktop entry template
- `install_cursor_desktop.sh` - Basic installation script (legacy)
- `setup_cursor_ubuntu.sh` - Comprehensive setup script (legacy)
- `uninstall_cursor_desktop.sh` - Enhanced uninstallation script

## Installation

**Before you begin:**
Download the latest Cursor AppImage from the [official website](https://www.cursor.so/download) and place it in your preferred directory (e.g., `~/Applications/`).

### Option 1: Environment-Based Setup (Recommended)

1. **Set up your environment configuration:**
   ```bash
   chmod +x setup_env.sh
   ./setup_env.sh
   ```
   This will create a `.env` file with your personal configuration.

2. **Install Cursor desktop integration:**
   ```bash
   chmod +x setup_cursor_env.sh
   ./setup_cursor_env.sh install
   ```

### Option 2: Manual Environment Setup

1. **Copy the example environment file:**
   ```bash
   cp env.example .env
   ```

2. **Edit the `.env` file with your configuration:**
   ```bash
   nano .env
   ```
   
   Example configuration:
   ```bash
   CURSOR_APPIMAGE_PATH=/home/username/Applications/Cursor-AppImage.AppImage
   USERNAME=username
   APPLICATIONS_DIR=/home/username/Applications
   ```

3. **Install Cursor desktop integration:**
   ```bash
   chmod +x setup_cursor_env.sh
   ./setup_cursor_env.sh install
   ```

### Option 3: Legacy Installation (Not Recommended)

1. Make sure Cursor AppImage is installed in your Applications directory
2. Make the setup script executable:
   ```bash
   chmod +x setup_cursor_ubuntu.sh
   ```
3. Run the comprehensive setup script:
   ```bash
   ./setup_cursor_ubuntu.sh
   ```

## Uninstallation

### Environment-Based Uninstallation (Recommended)

```bash
./setup_cursor_env.sh uninstall
```

### Legacy Uninstallation

```bash
chmod +x uninstall_cursor_desktop.sh
./uninstall_cursor_desktop.sh
```

Both methods will remove:
- Desktop entry
- Icon file
- Symlink
- MIME type associations

## Troubleshooting

- If Cursor doesn't appear immediately, try logging out and back in
- You can also restart your desktop environment:
  - GNOME: Alt+F2, type 'r', press Enter
  - Or restart your session
- Check that the Cursor AppImage path is correct
- Verify that the AppImage is executable: `chmod +x /path/to/your/Cursor-AppImage.AppImage`
- Test the AppImage directly: `/path/to/your/Cursor-AppImage.AppImage`
- Check if the desktop entry was created: `ls -la /usr/share/applications/cursor.desktop`
- Verify the icon: `ls -la /usr/share/pixmaps/cursor.png`

## Manual Installation

If you prefer to install manually:

1. Copy the `cursor.desktop` file to `/usr/share/applications/`
2. Make it executable: `sudo chmod +x /usr/share/applications/cursor.desktop`
3. Update the desktop database: `sudo update-desktop-database`

**Note:** The `cursor.desktop` file contains template paths that need to be updated with your actual Cursor AppImage path.