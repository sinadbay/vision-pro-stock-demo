import SwiftUI

@main
struct StockVisualizationApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 800, height: 600, depth: 400)
        
        ImmersiveSpace(id: "ImmersiveStockSpace") {
            ImmersiveStockView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
