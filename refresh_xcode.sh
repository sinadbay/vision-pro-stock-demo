#!/bin/bash

echo "🔄 Forcing Xcode to refresh and recognize new files..."

# Close Xcode if it's running
echo "1️⃣ Closing Xcode..."
killall Xcode 2>/dev/null || echo "   Xcode was not running"

# Clear all Xcode caches
echo "2️⃣ Clearing Xcode caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode*
rm -rf ./.build

# Remove user-specific files that might be cached
echo "3️⃣ Cleaning user data..."
find . -name "*.xcuserstate" -delete
find . -name "xcuserdata" -type d -exec rm -rf {} + 2>/dev/null || true

# Verify all source files exist
echo "4️⃣ Verifying source files..."
SOURCE_FILES=(
    "VisionProStockDemo/App.swift"
    "VisionProStockDemo/Views/ContentView.swift"
    "VisionProStockDemo/Models/StockData.swift"
    "VisionProStockDemo/Services/StockDataService.swift"
    "VisionProStockDemo/Views/Widgets/StockChartWidget.swift"
    "VisionProStockDemo/Views/Widgets/VolumeWidget.swift"
    "VisionProStockDemo/Views/Widgets/MarketOverviewWidget.swift"
    "VisionProStockDemo/Views/ImmersiveStockView.swift"
    "VisionProStockDemo/Info.plist"
)

ALL_PRESENT=true
for file in "${SOURCE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ $file NOT FOUND"
        ALL_PRESENT=false
    fi
done

if [ "$ALL_PRESENT" = false ]; then
    echo "❌ Some files are missing. Please check the file structure."
    exit 1
fi

# Touch the project file to force Xcode to reload
echo "5️⃣ Refreshing project file..."
touch VisionProStockDemo.xcodeproj/project.pbxproj

# Create a fresh workspace
echo "6️⃣ Creating fresh workspace data..."
mkdir -p VisionProStockDemo.xcodeproj/project.xcworkspace
mkdir -p VisionProStockDemo.xcodeproj/xcuserdata

# Wait a moment for file system to sync
sleep 1

# Open the project with a clean slate
echo "7️⃣ Opening project in Xcode..."
open VisionProStockDemo.xcodeproj

echo ""
echo "✅ Done! Xcode should now recognize all files."
echo ""
echo "📋 In Xcode, if files still don't appear:"
echo "   1. Go to Product → Clean Build Folder (Cmd+Shift+K)"
echo "   2. Close and reopen the project"
echo "   3. Check File → Project Settings → Derived Data and click Delete"
echo "   4. Right-click project root → Add Files and re-add missing files"
echo ""
echo "🎯 Try building now: Product → Build (Cmd+B)"
