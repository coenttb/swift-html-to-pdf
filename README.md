# HtmlToPdf

This Swift package extends String with a convenient interface for performantly converting HTML strings into PDF documents on iOS and macOS.

## Features

- Convert HTML strings to PDF documents on both iOS and macOS.
- Customize margins for PDF documents.
- Asynchronous operations for smooth and efficient processing.
- Support for batch processing of multiple documents.
- Swift 6 language mode enabled

## Installation

To install the package, add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-html-to-pdf.git", from: "0.1.0")
]
```

## Performance
The package includes a test that prints 1000 html strings to pdfs in 1.25 seconds.

```swift
    @Test func collection() async throws {
        [...]
        let count = 10_000
        await [String].init(repeating: "<html><body><h1>Hello, World 1!</h1></body></html>", count: count)
            .print(to: [...])
        [...]
    }
```


## Examples

Print to a file url:
```swift
let fileUrl = URL(...)
let html = "<html><body><h1>Hello, World 1!</h1></body></html>"
html.print(to: fileUrl)
```
Print to a directory with a file title.
```swift
let directory = URL(...)
let html = "<html><body><h1>Hello, World 1!</h1></body></html>"
html.print(title: "file title", to: directory)
```

Print a collection to a directory.
```swift
let directory = URL(...)
[
    html,
    html,
    html,
    ....
]
.print(to: fileUrl)
```

