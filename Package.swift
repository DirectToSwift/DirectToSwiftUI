// swift-tools-version:5.1

import PackageDescription

let package = Package(
  
  name: "DirectToSwiftUI",
  
  platforms: [
    .macOS(.v10_15), .iOS(.v13), .watchOS(.v6)
  ],
  
  products: [
    .library(name: "DirectToSwiftUI", targets: [ "DirectToSwiftUI" ])
  ],
  
  dependencies: [
    .package(url: "https://github.com/DirectToSwift/SwiftUIRules.git",
             from: "0.2.0"),
    .package(url: "https://github.com/ZeeQL/ZeeQL3.git",
             "0.9.4"..."0.9.8"),
    .package(url: "https://github.com/ZeeQL/ZeeQL3Combine.git",
             "0.1.5"..."0.1.5")
  ],
  
  targets: [
    .target(name: "DirectToSwiftUI", 
            dependencies: [ "SwiftUIRules", "ZeeQL", "ZeeQLCombine" ])
  ]
)
