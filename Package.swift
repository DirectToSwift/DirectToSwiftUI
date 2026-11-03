// swift-tools-version:6.0

import PackageDescription

let package = Package(
  
  name: "DirectToSwiftUI",
  
  platforms: [
    .macOS(.v12), .iOS(.v15), .watchOS(.v9)
  ],
  
  products: [
    .library(name: "DirectToSwiftUI", targets: [ "DirectToSwiftUI" ])
  ],
  
  dependencies: [
    .package(url: "https://github.com/DirectToSwift/SwiftUIRules.git",
             from: "0.2.0"),
    .package(url: "https://github.com/ZeeQL/ZeeQL3.git",
             from: "0.10.1"),
    .package(url: "https://github.com/ZeeQL/ZeeQL3Combine.git",
             from: "0.2.1")
  ],
  
  targets: [
    .target(name: "DirectToSwiftUI", 
            dependencies: [
              "SwiftUIRules",
              .product(name: "ZeeQL",        package: "ZeeQL3"),
              .product(name: "ZeeQLCombine", package: "ZeeQL3Combine")
            ])
  ],
  
  // TODO: Port to the Swift 6 language mode (strict concurrency checks).
  swiftLanguageModes: [ .v5 ]
)
