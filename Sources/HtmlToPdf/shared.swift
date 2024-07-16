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
            .map { index, html in
                Document(
                    url: directory
                        .appendingPathComponent(filename(index))
                        .appendingPathExtension("pdf"),
                    html: html
                )
            }
            .print(
                to: directory,
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
        to directory: URL,
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

public struct PDFConfiguration: Sendable {
    let paperSize: CGRect
    let margins: NSEdgeInsets
    
    var rect: CGRect {
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
    public static let a4: PDFConfiguration = .a4(margins: .a4)
}

extension WKPDFConfiguration {
    public convenience init(
        configuration: PDFConfiguration
    ){
        self.init()
        self.rect = configuration.rect
    }
}

class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    let window: NSWindow
    private let outputURL: URL
    var onFinished: (@Sendable () -> Void)?
    
    private let configuration: PDFConfiguration
    
    init(
        window: NSWindow,
        outputURL: URL,
        configuration: PDFConfiguration
    ) {
        self.window = window
        self.outputURL = outputURL
        self.configuration = configuration
    }
    
    @objc func printOperationDidRun(_ printOperation: NSPrintOperation, success: Bool, contextInfo: UnsafeMutableRawPointer?) {
        if let onFinished {
            onFinished()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor [window, configuration, outputURL, onFinished] in
            
            webView.frame = configuration.paperSize

            let printOperation = webView.printOperation(with: .pdf(url: outputURL))
                       
            printOperation.showsPrintPanel = false
            printOperation.showsProgressPanel = false
            printOperation.runModal(for: window, delegate: PrintDelegate.init(onFinished: onFinished), didRun: #selector(printOperationDidRun(_:success:contextInfo:)), contextInfo: nil)
            
        }
    }
}

class PrintDelegate {
    
    var onFinished: (@Sendable () -> Void)?
    
    init(onFinished: (@Sendable () -> Void)? = nil) {
        self.onFinished = onFinished
    }
    
    @objc func printOperationDidRun(_ printOperation: NSPrintOperation, success: Bool, contextInfo: UnsafeMutableRawPointer?) {
        if let onFinished {
            print("printOperationDidRun.success", success)
            print("printOperationDidRun.printOperation", printOperation)
            onFinished()
        }
    }
}

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
