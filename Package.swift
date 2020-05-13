// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "photons",
    
    products: [
        .library(name: "photons", targets: ["photons"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "photons", dependencies: []),
        .testTarget(name: "photonsTests", dependencies: ["photons"]),
    ]
)
