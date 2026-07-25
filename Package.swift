// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GlitchSoundFX",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "GlitchSoundFX", targets: ["GlitchSoundFX"])
    ],
    targets: [
        .target(
            name: "GlitchSoundFX",
            path: "GlitchSoundFX/GlitchSoundFX"
        ),
        .testTarget(
            name: "GlitchSoundFXTests",
            dependencies: ["GlitchSoundFX"]
        )
    ]
)
