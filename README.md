# HtmlToPdf

HtmlToPdf provides an easy-to-use interface for printing HTML to PDF on iOS and macOS.

## Features

- Convert HTML strings to PDF documents on both iOS and macOS.
- Lightweight and fast: it can handle thousands of documents quickly.
- Customize margins for PDF documents.
- Swift 6 language mode enabled

## Performance

The package includes a test that prints 1000 html strings to pdfs in 11 seconds.

```swift
@Test func collection() async throws {
    [...]
    let count = 1_000
    try await [String].init(
        repeating: "<html><body><h1>Hello, World 1!</h1></body></html>",
        count: count
    )
    .print(to: output)
    [...]
}
```

## Examples

Print to a file url:
```swift
let fileUrl = URL(...)
let html = "<html><body><h1>Hello, World 1!</h1></body></html>"
try await html.print(to: fileUrl)
```
Print to a directory with a file title.
```swift
let directory = URL(...)
let html = "<html><body><h1>Hello, World 1!</h1></body></html>"
try await  html.print(title: "file title", to: directory)
```

Print a collection to a directory.
```swift
let directory = URL(...)
try await [
    html,
    html,
    html,
    ....
]
.print(to: directory)
```

### ``AsyncStream<URL>``

Optionally, you can invoke an overload that returns an ``AsyncStream<URL>`` that yields the URL of each printed PDF.
> [!NOTE] 
> it is required to include the ``AsyncStream`` in the variable declaration.

```swift
let directory = URL(...)
let urls: AsyncStream = try await [
    html,
    html,
    html,
    ....
]
.print(to: directory)

for await url in urls {
    Swift.print(url)
}
```

## Installation

To install the package, add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-html-to-pdf.git", from: "0.1.0")
]
```

You can then make HtmlToPdf available to your Package's target by including HtmlToPdf in your target's dependencies as follows:
```swift
targets: [
    .target(
        name: "TheNameOfYourTarget",
        dependencies: [
            .product(name: "HtmlToPdf", package: "swift-html-to-pdf")
        ]
    )
]
```
