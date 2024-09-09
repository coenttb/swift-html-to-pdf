# HtmlToPdf

HtmlToPdf provides an easy-to-use interface for concurrently printing HTML to PDF on iOS and macOS.

## Features

- Convert HTML strings to PDF documents on both iOS and macOS.
- Lightweight and fast: it can handle thousands of documents quickly.
- Customize margins for PDF documents.
- Swift 6 language mode enabled
- And one more thing: easily print images in your PDFs!

## Examples

Print to a file url:
```swift
try await "<html><body><h1>Hello, World 1!</h1></body></html>".print(to: URL(...))
```
Print to a directory with a file title.
```swift
let directory = URL(...)
let html = "<html><body><h1>Hello, World 1!</h1></body></html>"
try await html.print(title: "file title", to: directory)
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

## Performance

The package includes a test that prints 1000 HTML strings to PDFs in ~2.6 seconds (using ``UIPrintPageRenderer`` on iOS or Mac Catalyst) or ~12 seconds (using ``NSPrintOperation`` on MacOS).

```swift
@Test func collection() async throws {
    [...]
    let count = 1_000
    try await [String].init(
        repeating: "<html><body><h1>Hello, World 1!</h1></body></html>",
        count: count
    )
    .print(to: URL(...))
    [...]
}
```

### ``AsyncStream<URL>``

Optionally, you can invoke an overload that returns an ``AsyncStream<URL>`` that yields the URL of each printed PDF.
> [!NOTE] 
> You need to include the ``AsyncStream`` type signature in the variable declaration, otherwise the return value will be Void.

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

## Including Images in PDFs

HtmlToPdf supports base64-encoded images out of the box.

> [!Important]
> You are responsible for encoding your images to base64.  

> [!Tip]
> You can use swift to load the image from a relative or absolute path and then convert them to base64.
> Here's how you can achieve this using the convenience initializer on Image using `[coenttb/swift-html](https://www.github.com/coenttb/swift-html)` package:
> ```
> struct Example: HTML {
>     var body: some HTML {
>         [...]
>         if let image = Image(base64EncodedFromURL: "path/to/your/image.jpg", description: "Description of the image") {
>             image
>         }
>         [...]
>     }
> } 
> ```



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
