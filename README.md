# Vision Pro Stock Visualization Demo

A comprehensive stock market visualization platform built for Apple Vision Pro, featuring interactive 3D widgets and immersive data experiences.

## Features

### 🚀 Three Interactive Visualization Widgets

1. **Stock Price Chart Widget**
   - Interactive 3D line charts with real-time price data
   - Tap-to-select data points with detailed information
   - Smooth 3D rotation animations
   - Color-coded price trends (green/red for gains/losses)

2. **Volume Visualization Widget**
   - 3D volume bar charts with gradient styling
   - Interactive data point selection
   - Animated floating effects
   - Volume formatting (K/M abbreviations)

3. **Market Overview Widget**
   - Scrollable stock cards with real-time data
   - Market sentiment analysis (Bullish/Bearish/Mixed)
   - Interactive selection with scaling animations
   - Detailed stock information panels

### 🥽 Immersive Space Experience

- Fully immersive 3D stock market environment
- Floating 3D visualizations arranged in a circle
- Real-time data integration with RealityKit
- Interactive floating UI controls
- Dynamic lighting and materials

### 📊 Real-Time Data Integration

- Financial Modeling Prep API integration (free tier)
- Alpha Vantage API support (with API key)
- Fallback to realistic mock data for demo purposes
- Automatic data refresh capabilities
- Pull-to-refresh functionality

## Technologies Used

- **SwiftUI** - Modern UI framework
- **Swift Charts** - Native charting framework
- **RealityKit** - 3D rendering and immersive experiences
- **Combine** - Reactive programming for data management
- **URLSession** - Network requests for real-time data

## Getting Started

### Prerequisites

- Xcode 15.0 or later
- visionOS 1.0 SDK
- Apple Vision Pro device or simulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd visionprodemo
```

2. Open the project in Xcode:
```bash
open VisionProStockDemo.xcodeproj
```

3. Build and run on Vision Pro simulator or device

### API Configuration

The app includes multiple data sources:

1. **Free Tier (Default)**: Uses Financial Modeling Prep demo API
2. **Premium**: Configure Alpha Vantage API key in `StockDataService.swift`
3. **Demo Mode**: Realistic mock data for testing

To use real API data:
1. Get a free API key from [Financial Modeling Prep](https://financialmodelingprep.com/)
2. Update the API key in `StockDataService.swift`
3. Set `useRealAPI = true`

## Project Structure

```
VisionProStockDemo/
├── App.swift                     # Main app entry point
├── Models/
│   └── StockData.swift          # Data models and market data
├── Views/
│   ├── ContentView.swift        # Main dashboard view
│   ├── ImmersiveStockView.swift # Immersive 3D experience
│   └── Widgets/
│       ├── StockChartWidget.swift      # Price chart widget
│       ├── VolumeWidget.swift          # Volume visualization
│       └── MarketOverviewWidget.swift  # Market overview
├── Services/
│   └── StockDataService.swift   # API integration and data management
└── Info.plist                   # App configuration
```

## Key Features Implemented

### Widget Interactions
- **Tap gestures** for data point selection
- **3D animations** and visual feedback
- **Real-time updates** with smooth transitions
- **Responsive design** for different screen sizes

### 3D Visualizations
- **Rotation effects** for enhanced depth perception
- **Gradient materials** and lighting
- **Interactive charts** with hover states
- **Floating animations** for dynamic effects

### Data Management
- **Reactive data binding** with `@Published` properties
- **Automatic refresh** mechanisms
- **Error handling** with fallback strategies
- **Efficient network requests** with proper cancellation

## Sample Data

The app includes realistic sample data for major stocks:
- AAPL (Apple Inc.)
- GOOGL (Alphabet Inc.)
- MSFT (Microsoft Corporation)
- TSLA (Tesla Inc.)
- AMZN (Amazon.com Inc.)

Historical data spans 30 days with realistic price movements and volume data.

## Future Enhancements

- [ ] Additional chart types (candlestick, area charts)
- [ ] Portfolio tracking and management
- [ ] Real-time news integration
- [ ] Advanced technical indicators
- [ ] Social sentiment analysis
- [ ] Multi-timeframe analysis
- [ ] Watchlist customization
- [ ] Price alerts and notifications

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is for educational and demonstration purposes. Please ensure compliance with financial data provider terms of service when using real APIs.

## Acknowledgments

- Financial data provided by Financial Modeling Prep
- Chart visualizations powered by Swift Charts
- 3D rendering enabled by RealityKit
- Built for Apple Vision Pro platform
