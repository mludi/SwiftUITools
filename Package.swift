// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SwiftUITools",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(name: "SwiftUITools", targets: ["SwiftUITools"]),
    ],
    targets: [
        .target(name: "SwiftUITools", dependencies: []),
    ]
)
