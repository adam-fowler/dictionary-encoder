// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "DictionaryEncoder",
    products: [
        .library(name: "DictionaryEncoder", targets: ["DictionaryEncoder"])
    ],
    targets: [
        .target(name: "DictionaryEncoder"),
        .testTarget(name: "DictionaryEncoderTests", dependencies: ["DictionaryEncoder"])
    ]
)
