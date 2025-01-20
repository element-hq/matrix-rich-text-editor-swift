// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let checksum = "642dec9e2ce6c2d35d1b2bb23ec30e0900ac44c03949fb04a8b7c23cf4d7fe0e"
let version = "2.38.1"
let url = "https://github.com/element-hq/matrix-rich-text-editor-swift/releases/download/\(version)/WysiwygComposerFFI.xcframework.zip"
let package = Package(
    name: "WysiwygComposer",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "WysiwygComposer",
            targets: ["WysiwygComposer"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Cocoanetics/DTCoreText",
            exact: "1.6.26"
        )
    ],
    targets: [
        .target(
            name: "DTCoreTextExtended",
            dependencies: [
                .product(name: "DTCoreText", package: "DTCoreText"),
            ]
        ),
        .target(
            name: "HTMLParser",
            dependencies: [
                .product(name: "DTCoreText", package: "DTCoreText"),
                .target(name: "DTCoreTextExtended"),
            ]
        ),
        .binaryTarget(
            name: "WysiwygComposerFFI",
            url: url,
            checksum: checksum
        ),
        .target(
            name: "WysiwygComposer",
            dependencies: [
                .target(name: "WysiwygComposerFFI"),
                .target(name: "HTMLParser"),
            ]
        )
    ]
)
