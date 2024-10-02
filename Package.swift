// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let checksum = "21a24b9bead1fc5836ab4e5ac60289dba7c6acc2a88668b1f989d5235f502bdd"
let version = "2.37.12"
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
