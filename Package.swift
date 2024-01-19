// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "sieve-swift",
    products: [
        .library(
            name: "SIEVE",
            targets: ["SIEVE"]),
    ],
    targets: [
        .target(
            name: "SIEVE"),
        .testTarget(
            name: "SIEVETests",
            dependencies: ["SIEVE"]),
    ]
)
