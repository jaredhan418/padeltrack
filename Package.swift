// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PadelTrack",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PadelTrackCore",
            targets: ["PadelTrackCore"]
        ),
        .library(
            name: "PadelTrack",
            targets: ["PadelTrack"]
        )
    ],
    targets: [
        // Pure-Swift core: models + platform-agnostic services (compiles on Linux too).
        .target(
            name: "PadelTrackCore",
            path: "PadelTrack/Sources/PadelTrackCore"
        ),
        // iOS/macOS UI + AVFoundation services.
        .target(
            name: "PadelTrack",
            dependencies: ["PadelTrackCore"],
            path: "PadelTrack/Sources/PadelTrack"
        ),
        // Unit tests for pure-Swift logic – runs on Linux/macOS without a device.
        .testTarget(
            name: "PadelTrackTests",
            dependencies: ["PadelTrackCore"],
            path: "PadelTrackTests"
        )
    ]
)
