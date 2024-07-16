import Foundation
import WebKit

extension [String] {
    /// Prints a collection of String to pdf's at the given directory.
    ///
    /// ## Example
    /// ```swift
    /// let htmls = [
    ///     "<html><body><h1>Hello, World 1!</h1></body></html>",
    ///     "<html><body><h1>Hello, World 1!</h1></body></html>",
    ///     ...
    /// ]
    /// try await htmls.print(to: .downloadsDirectory)
    /// ```
    ///
    /// - Parameters:
    ///   - directory: The directory at which to print the documents.
    ///   - configuration: The configuration that the pdfs will use.
    ///   - fileName: A closure that, given an Int that represents the index of the String in the collection, returns a fileName. Defaults to just the Index + 1.
    ///   - processorCount: In allmost all circumstances you can omit this parameter.
    ///
    public func print(
        to directory: URL,
        configuration: PDFConfiguration = .a4,
        filename: (Int) -> String = { index in "\(index + 1)" },
        processorCount: Int = ProcessInfo.processInfo.activeProcessorCount
    ) async throws {
        try await self.enumerated()
            .map { (index, html) in
                Document(
                    url: directory
                        .appendingPathComponent(filename(index))
                        .appendingPathExtension("pdf"),
                    html: html
                )
            }
            .print(
                configuration: configuration,
                processorCount: processorCount
            )
    }
}

extension [Document] {
    /// Prints documents  to pdf's at the given directory.
    ///
    /// ## Example
    /// ```swift
    /// let htmls = [
    ///     "<html><body><h1>Hello, World 1!</h1></body></html>",
    ///     "<html><body><h1>Hello, World 1!</h1></body></html>",
    ///     ...
    /// ]
    /// try await htmls.print(to: .downloadsDirectory)
    /// ```
    ///
    /// - Parameters:
    ///   - directory: The directory at which to print the documents.
    ///   - configuration: The configuration that the pdfs will use.
    ///   - processorCount: In allmost all circumstances you can omit this parameter.
    ///
    public func print(
//        to directory: URL,
        configuration: PDFConfiguration,
        processorCount: Int = ProcessInfo.processInfo.activeProcessorCount
    ) async throws {
        let webViewPool = await WebViewPool(size: processorCount)
        
        let stream = AsyncStream { continuation in
            Task {
                for document in self {
                    continuation.yield(document)
                }
                continuation.finish()
            }
        }
        
        await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for _ in 0..<processorCount {
                taskGroup.addTask {
                    for await document in stream {
                        let webView = await webViewPool.acquire()
                        try await document.html.print(
                            to: document.url
                                .deletingPathExtension()
                                .appendingPathExtension("pdf"),
                            configuration: configuration,
                            using: webView
                        )
                        await webViewPool.release(webView)
                    }
                }
            }
        }
    }
}

public struct EdgeInsets: Sendable {
    let top: CGFloat
    let left: CGFloat
    let bottom: CGFloat
    let right: CGFloat
    
    public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}

extension EdgeInsets {
    public static var a4: EdgeInsets {
        EdgeInsets(
            top: -36,
            left: -36,
            bottom: -36,
            right: -36
        )
    }
}

public struct PDFConfiguration: Sendable {
    let paperSize: CGSize
    let margins: EdgeInsets
    
    var printableRect: CGRect {
        let pageWidth: CGFloat = paperSize.width
        let pageHeight: CGFloat = paperSize.height
        let printableWidth = pageWidth - margins.left - margins.right
        let printableHeight = pageHeight - margins.top - margins.bottom
        
        return CGRect(
            x: margins.left,
            y: margins.top,
            width: printableWidth,
            height: printableHeight
        )
    }
}

extension PDFConfiguration {
    public static var a4: PDFConfiguration {
        .a4(margins: .a4)
    }
}

//extension WKPDFConfiguration {
//    public convenience init(
//        configuration: PDFConfiguration
//    ){
//        self.init()
//        self.rect = configuration.printableRect
//    }
//}





public struct Document: Sendable {
    let url: URL
    let html: String

    public init(
        url: URL,
        html: String
    ) {
        self.url = url
        self.html = html
    }
}

@MainActor
class WebViewPool {
    private var pool: [WKWebView]
    private let semaphore: DispatchSemaphore
    
    init(size: Int) {
        self.pool = (0..<size).map { _ in
            WKWebView(frame: .zero)
        }
        self.semaphore = DispatchSemaphore(value: size)
    }
    
    func acquire() -> WKWebView {
        semaphore.wait()
        return pool.removeFirst()
    }
    
    func release(_ webView: WKWebView) {
        pool.append(webView)
        semaphore.signal()
    }
}
