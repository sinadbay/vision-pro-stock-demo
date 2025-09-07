#!/bin/bash

echo "🥽 Setting up Vision Pro destinations for Xcode..."

# Check if visionOS SDK is available
echo "1️⃣ Checking visionOS SDK..."
if xcodebuild -showsdks | grep -q "xros"; then
    echo "   ✅ visionOS SDK found:"
    xcodebuild -showsdks | grep "xros"
else
    echo "   ❌ visionOS SDK not found!"
    echo "   Please install visionOS SDK in Xcode:"
    echo "   1. Open Xcode"
    echo "   2. Go to Xcode → Settings → Platforms"
    echo "   3. Download and install visionOS"
    exit 1
fi

# Check for Vision Pro simulators
echo ""
echo "2️⃣ Checking Vision Pro simulators..."
VISION_SIMS=$(xcrun simctl list devices | grep -i "apple vision")
if [ -n "$VISION_SIMS" ]; then
    echo "   ✅ Vision Pro simulators found:"
    echo "$VISION_SIMS"
else
    echo "   ⚠️  No Vision Pro simulators found. Creating one..."
    
    # Get the latest visionOS runtime
    RUNTIME=$(xcrun simctl list runtimes | grep -i "visionos" | tail -1 | awk '{print $NF}' | sed 's/[()]//g')
    
    if [ -n "$RUNTIME" ]; then
        echo "   Creating Vision Pro simulator with runtime: $RUNTIME"
        xcrun simctl create "Apple Vision Pro" "Apple Vision Pro" "$RUNTIME"
        echo "   ✅ Vision Pro simulator created"
    else
        echo "   ❌ No visionOS runtime found. Please install visionOS in Xcode."
        exit 1
    fi
fi

# Kill Xcode to force refresh
echo ""
echo "3️⃣ Refreshing Xcode..."
killall Xcode 2>/dev/null || echo "   Xcode was not running"

# Clear derived data
echo "4️⃣ Clearing Xcode cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode*

# Touch project to force reload
echo "5️⃣ Refreshing project..."
touch VisionProStockDemo.xcodeproj/project.pbxproj

# Wait a moment
sleep 2

# Open Xcode
echo "6️⃣ Opening Xcode..."
open VisionProStockDemo.xcodeproj

echo ""
echo "✅ Setup complete!"
echo ""
echo "🎯 In Xcode:"
echo "   1. Wait for project to load completely"
echo "   2. Look for 'Apple Vision Pro' in the destination dropdown"
echo "   3. If still showing 'No destinations', try:"
echo "      - Product → Clean Build Folder (Cmd+Shift+K)"
echo "      - Restart Xcode completely"
echo "      - Check Project Settings → Deployment Info"
echo ""
echo "💡 The destination should appear as:"
echo "   'Apple Vision Pro (Simulator)' or similar"
