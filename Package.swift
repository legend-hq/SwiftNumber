// swift-tools-version:5.9
//
//  Package.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2016-01-12.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend.

import PackageDescription

let package = Package(
    name: "SwiftNumber",
    platforms: [
        .macOS(.v13),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v4),
        .macCatalyst(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "SwiftNumber", targets: ["SwiftNumber"])
    ], 
    targets: [
        .target(name: "SwiftNumber", path: "Sources"),
        .testTarget(name: "SwiftNumberTests", dependencies: ["SwiftNumber"], path: "Tests")
    ]
)
