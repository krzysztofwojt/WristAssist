// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Nadgar",
    platforms: [
        .iOS(.v18),
        .watchOS(.v11),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "NadgarShared",
            targets: ["NadgarShared"]
        ),
        .executable(
            name: "NadgarSharedSmokeTests",
            targets: ["NadgarSharedSmokeTests"]
        )
    ],
    targets: [
        .target(
            name: "NadgarShared",
            path: "Sources/NadgarShared"
        ),
        .testTarget(
            name: "NadgarSharedTests",
            dependencies: ["NadgarShared"],
            path: "Tests/NadgarSharedTests"
        ),
        .executableTarget(
            name: "NadgarSharedSmokeTests",
            dependencies: ["NadgarShared"],
            path: "Tools/NadgarSharedSmokeTests"
        )
    ]
)
