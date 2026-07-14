// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GlitchFX",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "GlitchFX", targets: ["GlitchFX"])
    ],
    targets: [
        .target(
            name: "GlitchFX",
            path: "GlitchFX/GlitchFX"
        ),
        .testTarget(
            name: "GlitchFXTests",
            dependencies: ["GlitchFX"]
        )
    ]
)
