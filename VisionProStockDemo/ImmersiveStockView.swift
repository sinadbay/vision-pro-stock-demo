import SwiftUI
import RealityKit

struct ImmersiveStockView: View {
    @StateObject private var marketData = MarketData()
    @State private var rotationAngle: Float = 0
    @State private var selectedStock = "AAPL"
    
    var body: some View {
        ZStack {
            // Immersive 3D environment
            RealityView { content in
                setupImmersiveScene(content: content)
            } update: { content in
                updateScene(content: content)
            }
            
            // Floating UI controls
            VStack {
                HStack {
                    Text("Immersive Stock Market")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button("Exit") {
                        // Handle exit
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                Spacer()
                
                // Floating stock selector
                HStack {
                    ForEach(marketData.watchlist, id: \.self) { symbol in
                        Button(symbol) {
                            selectedStock = symbol
                        }
                        .buttonStyle(.borderedProminent)
                        .background(selectedStock == symbol ? .blue : .clear)
                    }
                }
                .padding()
                
                // Floating data panel
                if let stock = marketData.stocks.first(where: { $0.symbol == selectedStock }) {
                    StockInfoPanel(stock: stock)
                        .frame(width: 300, height: 150)
                        .padding()
                }
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                rotationAngle += 0.01
            }
        }
    }
    
    private func setupImmersiveScene(content: RealityViewContent) {
        // Create a 3D visualization space
        let anchor = AnchorEntity(world: [0, 0, -2])
        
        // Add ambient lighting
        let lightEntity = Entity()
        lightEntity.components.set(DirectionalLightComponent(
            color: .white,
            intensity: 1000,
            isRealWorldProxy: false
        ))
        lightEntity.position = [0, 2, 0]
        lightEntity.look(at: [0, 0, 0], from: lightEntity.position, relativeTo: nil)
        anchor.addChild(lightEntity)
        
        // Create 3D stock data visualization
        createStockVisualization(parent: anchor)
        
        content.add(anchor)
    }
    
    private func updateScene(content: RealityViewContent) {
        // Update 3D elements based on data changes
        for entity in content.entities {
            if let anchor = entity as? AnchorEntity {
                for child in anchor.children {
                    if child.name.starts(with: "stock_") {
                        // Rotate stock visualizations
                        child.transform.rotation = simd_quatf(angle: rotationAngle, axis: [0, 1, 0])
                    }
                }
            }
        }
    }
    
    private func createStockVisualization(parent: AnchorEntity) {
        let stockCount = marketData.stocks.count
        let radius: Float = 1.5
        
        for (index, stock) in marketData.stocks.enumerated() {
            let angle = Float(index) * (2 * .pi) / Float(stockCount)
            let x = cos(angle) * radius
            let z = sin(angle) * radius
            
            // Create 3D bar for stock price
            let height = Float(stock.price / 200.0) // Normalize height
            let mesh = MeshResource.generateBox(width: 0.2, height: height, depth: 0.2)
            let material = SimpleMaterial(
                color: stock.change >= 0 ? .green : .red,
                isMetallic: true
            )
            
            let stockEntity = ModelEntity(mesh: mesh, materials: [material])
            stockEntity.position = [x, height / 2, z]
            stockEntity.name = "stock_\(stock.symbol)"
            
            // Add text label
            let textMesh = MeshResource.generateText(
                stock.symbol,
                extrusionDepth: 0.02,
                font: .systemFont(ofSize: 0.1),
                containerFrame: .zero,
                alignment: .center,
                lineBreakMode: .byWordWrapping
            )
            let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
            let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
            textEntity.position = [0, height + 0.2, 0]
            
            stockEntity.addChild(textEntity)
            parent.addChild(stockEntity)
        }
    }
}

struct StockInfoPanel: View {
    let stock: StockQuote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stock.symbol)
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Text(String(format: "$%.2f", stock.price))
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Label("Change", systemImage: stock.change >= 0 ? "arrow.up" : "arrow.down")
                    .foregroundColor(stock.change >= 0 ? .green : .red)
                Spacer()
                Text(String(format: "%.2f (%.2f%%)", stock.change, stock.changePercent))
                    .foregroundColor(stock.change >= 0 ? .green : .red)
                    .fontWeight(.medium)
            }
            
            HStack {
                Label("Volume", systemImage: "chart.bar")
                    .foregroundColor(.blue)
                Spacer()
                Text("\(formatVolume(stock.volume))")
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
            }
            
            Text("Last updated: \(formatTime(stock.timestamp))")
                .font(.caption)
                .foregroundColor(.secondary)
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
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
