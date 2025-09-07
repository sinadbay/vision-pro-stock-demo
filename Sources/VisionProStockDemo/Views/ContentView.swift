import SwiftUI

struct ContentView: View {
    @StateObject private var marketData = MarketData()
    @StateObject private var stockService = StockDataService()
    @State private var showImmersiveSpace = false
    @State private var selectedStock = "AAPL"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Stock Market Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        showImmersiveSpace.toggle()
                    }) {
                        Label("Immersive View", systemImage: "visionpro")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                // Stock selector
                Picker("Select Stock", selection: $selectedStock) {
                    ForEach(marketData.watchlist, id: \.self) { symbol in
                        Text(symbol).tag(symbol)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Three visualization widgets
                HStack(spacing: 20) {
                    // Widget 1: Stock Price Chart
                    StockChartWidget(
                        stockSymbol: selectedStock,
                        historicalData: marketData.historicalData[selectedStock] ?? []
                    )
                    .frame(width: 300, height: 250)
                    
                    // Widget 2: Volume Visualization
                    VolumeWidget(
                        stockSymbol: selectedStock,
                        historicalData: marketData.historicalData[selectedStock] ?? []
                    )
                    .frame(width: 300, height: 250)
                }
                
                // Widget 3: Market Overview
                MarketOverviewWidget(stocks: stockService.stocks.isEmpty ? marketData.stocks : stockService.stocks)
                    .frame(height: 200)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
        .onAppear {
            // Load real-time stock data
            stockService.fetchRealTimeData(for: marketData.watchlist)
        }
        .onOpenURL { url in
            if url.absoluteString == "immersive://stock" {
                showImmersiveSpace = true
            }
        }
        .refreshable {
            stockService.fetchRealTimeData(for: marketData.watchlist)
        }
    }
}
