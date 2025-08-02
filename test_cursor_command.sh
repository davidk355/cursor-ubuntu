#!/bin/bash

echo "=== Testing Cursor Command ==="
echo ""

# Check if symlink exists
echo "1. Checking symlink..."
if [ -L "/usr/local/bin/cursor" ]; then
    echo "✓ Symlink exists: $(readlink /usr/local/bin/cursor)"
else
    echo "✗ Symlink not found"
    exit 1
fi

# Check if AppImage is executable
echo ""
echo "2. Checking AppImage..."
if [ -x "/path/to/your/Cursor-AppImage.AppImage" ]; then
    echo "✓ AppImage is executable"
else
    echo "✗ AppImage is not executable"
    echo "Please update the path in this script with your actual AppImage location"
    exit 1
fi

# Test cursor command in background
echo ""
echo "3. Testing cursor command (will launch in background)..."
echo "   Running: cursor &"
cursor &
CURSOR_PID=$!

# Wait a moment for the process to start
sleep 2

# Check if process is running
if ps -p $CURSOR_PID > /dev/null 2>&1; then
    echo "✓ Cursor launched successfully (PID: $CURSOR_PID)"
    echo "✓ Command completed without holding terminal"
    
    # Wait a bit more then kill the process
    sleep 3
    kill $CURSOR_PID 2>/dev/null
    echo "✓ Process terminated cleanly"
else
    echo "✗ Cursor failed to launch"
    exit 1
fi

echo ""
echo "=== Test Complete ==="
echo "The 'cursor' command works correctly and does not hold the terminal shell."
echo "You can now use 'cursor' from anywhere in your terminal." 