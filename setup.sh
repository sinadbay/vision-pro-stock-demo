#!/bin/bash

# Vision Pro Stock Demo Setup Script

echo "🚀 Setting up Vision Pro Stock Visualization Demo..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode 15.0 or later."
    exit 1
fi

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -n 1 | sed 's/Xcode //')
REQUIRED_VERSION="15.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$XCODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Xcode version $XCODE_VERSION is too old. Please update to Xcode 15.0 or later."
    exit 1
fi

echo "✅ Xcode version $XCODE_VERSION detected"

# Check if visionOS SDK is available
if ! xcodebuild -showsdks | grep -q "xros"; then
    echo "❌ visionOS SDK not found. Please install the visionOS SDK in Xcode."
    echo "   Go to Xcode > Settings > Platforms and install visionOS"
    exit 1
fi

echo "✅ visionOS SDK available"

# Check if all source files exist
echo "📋 Checking source files..."

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

for file in "${SOURCE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file not found"
    fi
done

# Open project in Xcode
echo "🔧 Opening project in Xcode..."

if [ -f "VisionProStockDemo.xcodeproj/project.pbxproj" ]; then
    open VisionProStockDemo.xcodeproj
    echo "✅ Project opened in Xcode"
else
    echo "❌ Xcode project file not found"
    exit 1
fi

echo ""
echo "🎉 Setup complete! Your Vision Pro Stock Visualization Demo is ready."
echo ""
echo "📖 Next steps:"
echo "   1. Select 'Vision Pro' simulator in Xcode"
echo "   2. Press Cmd+R to build and run"
echo "   3. Explore the three interactive widgets"
echo "   4. Tap 'Immersive View' for the 3D experience"
echo ""
echo "📊 Data Sources:"
echo "   • Demo mode: Realistic mock data (default)"
echo "   • Real API: Configure API key in StockDataService.swift"
echo ""
echo "🔗 Documentation: See README.md for detailed information"
echo "🎬 Demo Guide: See Demo.md for presentation walkthrough"
