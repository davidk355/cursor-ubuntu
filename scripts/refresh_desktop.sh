#!/bin/bash

echo "=== Refreshing Desktop Environment ==="
echo "This will refresh the applications menu to show Cursor"
echo ""

# Update desktop database
echo "1. Updating desktop database..."
sudo update-desktop-database

# Update MIME database
echo "2. Updating MIME database..."
sudo update-mime-database /usr/share/mime

# Restart GNOME Shell (if using GNOME)
echo "3. Restarting GNOME Shell..."
if pgrep -x "gnome-shell" > /dev/null; then
    echo "   GNOME Shell detected, restarting..."
    busctl call --user org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")' 2>/dev/null || echo "   GNOME Shell restart attempted"
else
    echo "   GNOME Shell not detected"
fi

# Alternative: Restart the entire desktop session
echo ""
echo "4. Desktop refresh options:"
echo "   Option A: Log out and log back in"
echo "   Option B: Restart your computer"
echo "   Option C: Use Alt+F2, type 'r', press Enter (GNOME)"
echo ""

# Check if Cursor desktop entry is properly installed
echo "5. Verifying Cursor installation..."
if [ -f "/usr/share/applications/cursor.desktop" ]; then
    echo "   ✓ Desktop entry exists"
else
    echo "   ✗ Desktop entry missing"
fi

if [ -f "/usr/share/pixmaps/cursor.png" ]; then
    echo "   ✓ Icon exists"
else
    echo "   ✗ Icon missing"
fi

# Test the desktop entry
echo ""
echo "6. Testing desktop entry..."
if gtk-launch cursor > /dev/null 2>&1; then
    echo "   ✓ Desktop entry launches successfully"
else
    echo "   ✗ Desktop entry failed to launch"
fi

echo ""
echo "=== Refresh Complete ==="
echo "Cursor should now appear in your applications menu."
echo "If it doesn't appear, try logging out and back in." 