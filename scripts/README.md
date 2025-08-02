# Scripts

This directory contains all the scripts needed to set up and manage Cursor desktop integration on Ubuntu 24.

**Scripts in this folder:**

- `setup_env.sh`  
  Interactive script to create your personal `.env` configuration file.

- `setup_cursor_env.sh`  
  Main installer/uninstaller for Cursor desktop integration. Uses your `.env` file.

- `install_cursor_desktop.sh`  
  Installs the Cursor desktop entry and icon manually.

- `refresh_desktop.sh`  
  Refreshes the desktop database so new apps and icons appear.

- `fix_apparmor_cursor.sh`  
  Applies AppArmor fixes to allow Cursor to run on Ubuntu 24.

- `simple_apparmor_fix.sh`  
  A basic AppArmor workaround for Cursor (alternative to the main fix script).

Use these scripts as described in the main README to automate setup, installation, and troubleshooting.

