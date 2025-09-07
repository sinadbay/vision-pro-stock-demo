import SwiftUI
import Charts

struct StockChartWidget: View {
    let stockSymbol: String
    let historicalData: [HistoricalData]
    @State private var selectedDataPoint: HistoricalData?
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("\(stockSymbol) Price Chart")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(currentPrice)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(priceColor)
            }
            .padding(.horizontal)
            
            ZStack {
                // 3D Chart container
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .frame(height: 180)
                
                if !historicalData.isEmpty {
                    Chart(historicalData) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Price", data.close)
                        )
                        .foregroundStyle(.blue.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        AreaMark(
                            x: .value("Date", data.date),
                            y: .value("Price", data.close)
                        )
                        .foregroundStyle(.blue.opacity(0.3).gradient)
                        
                        if let selectedDataPoint = selectedDataPoint,
                           selectedDataPoint.id == data.id {
                            PointMark(
                                x: .value("Date", data.date),
                                y: .value("Price", data.close)
                            )
                            .foregroundStyle(.red)
                            .symbolSize(100)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 7)) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.month().day())
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                    .chartAngleSelection(value: .constant(nil))
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture { location in
                                    updateSelectedDataPoint(at: location, geometry: geometry, chartProxy: chartProxy)
                                }
                        }
                    }
                    .padding()
                } else {
                    Text("Loading chart data...")
                        .foregroundColor(.secondary)
                }
            }
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    rotation = 5
                }
            }
            
            if let selectedDataPoint = selectedDataPoint {
                HStack {
                    Text("Date: \(selectedDataPoint.dateString)")
                    Spacer()
                    Text("Price: $\(selectedDataPoint.close, specifier: "%.2f")")
                }
                .font(.caption)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            }
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private var currentPrice: String {
        guard let latest = historicalData.last else { return "$0.00" }
        return String(format: "$%.2f", latest.close)
    }
    
    private var priceColor: Color {
        guard historicalData.count >= 2 else { return .primary }
        let latest = historicalData[historicalData.count - 1].close
        let previous = historicalData[historicalData.count - 2].close
        return latest >= previous ? .green : .red
    }
    
    private func updateSelectedDataPoint(at location: CGPoint, geometry: GeometryProxy, chartProxy: ChartProxy) {
        let xPosition = location.x - geometry.frame(in: .local).minX
        
        if let date: Date = chartProxy.value(atX: xPosition) {
            if let closestDataPoint = historicalData.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
                selectedDataPoint = closestDataPoint
            }
        }
    }
}
