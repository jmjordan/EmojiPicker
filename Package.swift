// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "EmojiPicker",
    defaultLocalization: "en",
    platforms: [.iOS("15.0")],
    products: [
        .library(
            name: "EmojiPicker",
            targets: ["EmojiPicker"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "EmojiPicker",
            dependencies: [],
            resources: [.process("Resources")])
    ],
    swiftLanguageVersions: [.v4_2]
)
