// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let htmlToPdf: Self = "HtmlToPdf"
}

extension Target.Dependency {
    static var htmlToPdf: Self { .target(name: .htmlToPdf) }
}

let package = Package(
    name: "swift-html-to-pdf",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        .library(
            name: .htmlToPdf,
            targets: [.htmlToPdf]
        )
    ],
    targets: [
        .target(
            name: .htmlToPdf),
        .testTarget(
            name: .htmlToPdf + "Tests",
            dependencies: [.htmlToPdf]
        )
    ],
    swiftLanguageVersions: [.version("6")]
)
