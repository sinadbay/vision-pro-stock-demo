import Foundation
import Combine

class StockDataService: ObservableObject {
    @Published var stocks: [StockQuote] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiKey = "YOUR_API_KEY" // Replace with actual Alpha Vantage API key
    private let baseURL = "https://www.alphavantage.co/query"
    
    // For demo purposes, we'll use both real API and mock data
    private let useRealAPI = false // Set to true when you have API key
    
    func fetchStockData(for symbols: [String]) {
        if useRealAPI {
            fetchRealStockData(for: symbols)
        } else {
            generateMockData(for: symbols)
        }
    }
    
    private func fetchRealStockData(for symbols: [String]) {
        isLoading = true
        error = nil
        
        let group = DispatchGroup()
        var fetchedStocks: [StockQuote] = []
        
        for symbol in symbols {
            group.enter()
            fetchStockQuote(for: symbol) { [weak self] result in
                defer { group.leave() }
                
                switch result {
                case .success(let stock):
                    fetchedStocks.append(stock)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.error = error.localizedDescription
                    }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.stocks = fetchedStocks.sorted { $0.symbol < $1.symbol }
            self?.isLoading = false
        }
    }
    
    private func fetchStockQuote(for symbol: String, completion: @escaping (Result<StockQuote, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(apiKey)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(AlphaVantageResponse.self, from: data)
                let quote = response.globalQuote
                
                let stockQuote = StockQuote(
                    symbol: quote.symbol,
                    price: Double(quote.price) ?? 0,
                    change: Double(quote.change) ?? 0,
                    changePercent: Double(quote.changePercent.replacingOccurrences(of: "%", with: "")) ?? 0,
                    volume: Int(quote.volume) ?? 0,
                    timestamp: DateFormatter.apiDateFormatter.date(from: quote.latestTradingDay) ?? Date()
                )
                
                completion(.success(stockQuote))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func generateMockData(for symbols: [String]) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.stocks = symbols.map { symbol in
                StockQuote(
                    symbol: symbol,
                    price: Double.random(in: 100...400),
                    change: Double.random(in: -15...15),
                    changePercent: Double.random(in: -5...5),
                    volume: Int.random(in: 1_000_000...100_000_000),
                    timestamp: Date()
                )
            }
            self?.isLoading = false
        }
    }
    
    // Fetch real-time data using Financial Modeling Prep (free tier available)
    func fetchRealTimeData(for symbols: [String]) {
        let symbolsString = symbols.joined(separator: ",")
        guard let url = URL(string: "https://financialmodelingprep.com/api/v3/quote/\(symbolsString)?apikey=demo") else {
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received"
                    return
                }
                
                do {
                    let quotes = try JSONDecoder().decode([FMPQuote].self, from: data)
                    self?.stocks = quotes.map { quote in
                        StockQuote(
                            symbol: quote.symbol,
                            price: quote.price,
                            change: quote.change,
                            changePercent: quote.changesPercentage,
                            volume: quote.volume,
                            timestamp: Date()
                        )
                    }
                } catch {
                    self?.error = "Failed to parse data: \(error.localizedDescription)"
                    // Fallback to mock data
                    self?.generateMockData(for: symbols)
                }
            }
        }.resume()
    }
}

// Financial Modeling Prep API model
struct FMPQuote: Codable {
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changesPercentage: Double
    let volume: Int
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

extension DateFormatter {
    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
