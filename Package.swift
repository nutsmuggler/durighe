// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Durighe",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Durighe",
            targets: ["Durighe"]
        ),
    ],
    targets: [
        .target(
            name: "Durighe",
            dependencies: []
        ),
        .testTarget(
            name: "DurigheTests",
            dependencies: ["Durighe"]
        ),
    ]
)
