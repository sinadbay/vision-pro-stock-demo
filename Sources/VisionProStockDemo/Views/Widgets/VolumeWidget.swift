import SwiftUI
import Charts

struct VolumeWidget: View {
    let stockSymbol: String
    let historicalData: [HistoricalData]
    @State private var selectedVolume: HistoricalData?
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("\(stockSymbol) Volume")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(averageVolume)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)
            
            ZStack {
                // 3D Volume container
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .frame(height: 180)
                
                if !historicalData.isEmpty {
                    Chart(historicalData) { data in
                        BarMark(
                            x: .value("Date", data.date),
                            y: .value("Volume", data.volume)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .opacity(selectedVolume?.id == data.id ? 1.0 : 0.8)
                        
                        if let selectedVolume = selectedVolume,
                           selectedVolume.id == data.id {
                            RuleMark(
                                x: .value("Date", data.date)
                            )
                            .foregroundStyle(.white)
                            .lineStyle(StrokeStyle(lineWidth: 2))
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
                            AxisValueLabel { 
                                Text(formatVolume(value.as(Double.self) ?? 0))
                            }
                        }
                    }
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture { location in
                                    updateSelectedVolume(at: location, geometry: geometry, chartProxy: chartProxy)
                                }
                        }
                    }
                    .padding()
                    .offset(y: animationOffset)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            animationOffset = -2
                        }
                    }
                } else {
                    Text("Loading volume data...")
                        .foregroundColor(.secondary)
                }
            }
            .rotation3DEffect(.degrees(10), axis: (x: 1, y: 0, z: 0))
            
            if let selectedVolume = selectedVolume {
                HStack {
                    Text("Date: \(selectedVolume.dateString)")
                    Spacer()
                    Text("Volume: \(formatVolume(Double(selectedVolume.volume)))")
                }
                .font(.caption)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            }
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private var averageVolume: String {
        guard !historicalData.isEmpty else { return "0" }
        let total = historicalData.reduce(0) { $0 + $1.volume }
        let average = Double(total) / Double(historicalData.count)
        return formatVolume(average)
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1_000_000 {
            return String(format: "%.1fM", volume / 1_000_000)
        } else if volume >= 1_000 {
            return String(format: "%.1fK", volume / 1_000)
        }
        return String(format: "%.0f", volume)
    }
    
    private func updateSelectedVolume(at location: CGPoint, geometry: GeometryProxy, chartProxy: ChartProxy) {
        let xPosition = location.x - geometry.frame(in: .local).minX
        
        if let date: Date = chartProxy.value(atX: xPosition) {
            if let closestDataPoint = historicalData.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
                selectedVolume = closestDataPoint
            }
        }
    }
}
