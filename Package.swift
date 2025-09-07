// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VisionProStockDemo",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "VisionProStockDemo",
            targets: ["VisionProStockDemo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-charts.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "VisionProStockDemo",
            dependencies: [
                .product(name: "Charts", package: "swift-charts")
            ]
        ),
        .testTarget(
            name: "VisionProStockDemoTests",
            dependencies: ["VisionProStockDemo"]),
    ]
)
