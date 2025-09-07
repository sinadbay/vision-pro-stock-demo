import SwiftUI

struct MarketOverviewWidget: View {
    let stocks: [StockQuote]
    @State private var selectedStock: StockQuote?
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("Market Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(marketStatus)
                    .font(.subheadline)
                    .foregroundColor(marketStatusColor)
                    .fontWeight(.medium)
            }
            .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .frame(height: 150)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(stocks) { stock in
                            StockCard(
                                stock: stock,
                                isSelected: selectedStock?.id == stock.id
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedStock = selectedStock?.id == stock.id ? nil : stock
                                }
                            }
                            .rotation3DEffect(
                                .degrees(rotationAngle),
                                axis: (x: 0, y: 1, z: 0)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
            
            if let selectedStock = selectedStock {
                StockDetailView(stock: selectedStock)
                    .padding(.horizontal)
                    .transition(.slide)
            }
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private var marketStatus: String {
        let positiveStocks = stocks.filter { $0.change > 0 }.count
        let totalStocks = stocks.count
        
        if positiveStocks > totalStocks / 2 {
            return "Bullish Market"
        } else if positiveStocks < totalStocks / 2 {
            return "Bearish Market"
        } else {
            return "Mixed Market"
        }
    }
    
    private var marketStatusColor: Color {
        let positiveStocks = stocks.filter { $0.change > 0 }.count
        let totalStocks = stocks.count
        
        if positiveStocks > totalStocks / 2 {
            return .green
        } else if positiveStocks < totalStocks / 2 {
            return .red
        } else {
            return .orange
        }
    }
}

struct StockCard: View {
    let stock: StockQuote
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(stock.symbol)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(String(format: "$%.2f", stock.price))
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack(spacing: 4) {
                Image(systemName: stock.change >= 0 ? "arrow.up" : "arrow.down")
                    .font(.caption)
                Text(String(format: "%.2f%%", stock.changePercent))
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(stock.change >= 0 ? .green : .red)
        }
        .padding()
        .frame(width: 100, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? .blue.opacity(0.3) : .clear)
                .stroke(isSelected ? .blue : .gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: isSelected ? 10 : 0)
    }
}

struct StockDetailView: View {
    let stock: StockQuote
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Current Price")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(String(format: "$%.2f", stock.price))
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    Image(systemName: stock.change >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundColor(stock.change >= 0 ? .green : .red)
                    Text(String(format: "%.2f", stock.change))
                        .fontWeight(.semibold)
                        .foregroundColor(stock.change >= 0 ? .green : .red)
                }
                
                Text(String(format: "%.2f%%", stock.changePercent))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(stock.change >= 0 ? .green : .red)
                
                Text("Volume: \(formatVolume(stock.volume))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
    }
    
    private func formatVolume(_ volume: Int) -> String {
        if volume >= 1_000_000 {
            return String(format: "%.1fM", Double(volume) / 1_000_000)
        } else if volume >= 1_000 {
            return String(format: "%.1fK", Double(volume) / 1_000)
        }
        return String(volume)
    }
}
