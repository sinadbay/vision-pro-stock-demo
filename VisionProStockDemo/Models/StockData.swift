import Foundation

// MARK: - Stock Data Models
struct StockQuote: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: Double
    let volume: Int
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case price = "05. price"
        case change = "09. change"
        case changePercent = "10. change percent"
        case volume = "06. volume"
        case timestamp = "07. latest trading day"
    }
}

struct HistoricalData: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct MarketData: ObservableObject {
    @Published var stocks: [StockQuote] = []
    @Published var historicalData: [String: [HistoricalData]] = [:]
    @Published var isLoading = false
    @Published var error: String?
    
    // Sample symbols for demo
    let watchlist = ["AAPL", "GOOGL", "MSFT", "TSLA", "AMZN"]
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        // Generate sample data for demo purposes
        self.stocks = watchlist.map { symbol in
            StockQuote(
                symbol: symbol,
                price: Double.random(in: 100...300),
                change: Double.random(in: -10...10),
                changePercent: Double.random(in: -5...5),
                volume: Int.random(in: 1000000...50000000),
                timestamp: Date()
            )
        }
        
        // Generate historical data
        for symbol in watchlist {
            var history: [HistoricalData] = []
            var currentPrice = Double.random(in: 100...300)
            
            for i in 0..<30 {
                let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
                let variation = Double.random(in: -5...5)
                currentPrice += variation
                
                history.append(HistoricalData(
                    date: date,
                    open: currentPrice - Double.random(in: -2...2),
                    high: currentPrice + Double.random(in: 0...3),
                    low: currentPrice - Double.random(in: 0...3),
                    close: currentPrice,
                    volume: Int.random(in: 1000000...50000000)
                ))
            }
            
            self.historicalData[symbol] = history.sorted { $0.date < $1.date }
        }
    }
}

// MARK: - API Models (for future real API integration)
struct AlphaVantageResponse: Codable {
    let globalQuote: GlobalQuote
    
    enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
    }
}

struct GlobalQuote: Codable {
    let symbol: String
    let price: String
    let change: String
    let changePercent: String
    let volume: String
    let latestTradingDay: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case price = "05. price"
        case change = "09. change"
        case changePercent = "10. change percent"
        case volume = "06. volume"
        case latestTradingDay = "07. latest trading day"
    }
}
