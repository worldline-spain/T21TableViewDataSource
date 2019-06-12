// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "T21TableViewDataSource",
    products: [
        .library(
            name: "T21TableViewDataSource",
            targets: ["T21TableViewDataSource"]),
    ],
    targets: [
        .target(
            name: "T21TableViewDataSource",
            dependencies: [],
            path: "./src"),
    ]
)
