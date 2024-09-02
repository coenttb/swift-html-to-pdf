// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static var htmlToPdf: Self { "HtmlToPdf" }
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
    swiftLanguageVersions: [.v5]
)
