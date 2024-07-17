//
//  swift-html-to-pdf | macOS.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

#if os(macOS)
import Foundation
import WebKit

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
    ///   - configuration: The configuration that the pdfs will use.
    ///   - processorCount: In allmost all circumstances you can omit this parameter.
    ///
    
    
    public func print(
        configuration: PDFConfiguration,
        processorCount: Int = ProcessInfo.processInfo.activeProcessorCount
    ) async throws {
        
        let stream = AsyncStream { continuation in
            Task {
                for document in self {
                    continuation.yield(document)
                }
                continuation.finish()
            }
        }
        
//        A previous version worked like this and was much faster. However, it also caused
//        the tests to fail roughly half the time.
//
//        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
//            for _ in 0..<processorCount {
//                taskGroup.addTask {
//                    for await document in stream {
//
//                        let webView = try await WebViewPool.shared.acquireWithRetry()
//
//                        try await document.print(configuration: configuration, using: webView)
//                        
//                        await WebViewPool.shared.release(webView)
//                    }
//                }
//            }
//            try await taskGroup.waitForAll() // Wait for all tasks to complete
//        }
    
        
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for await document in stream {
                taskGroup.addTask {
                    
                    let webView = try await WebViewPool.shared.acquireWithRetry()
                    
                    try await document.print(configuration: configuration, using: webView)
                    
                    await WebViewPool.shared.release(webView)
                    
                }
                try await taskGroup.waitForAll()
            }
        }
    }
}

extension WebViewPool {
    enum Error: Swift.Error {
        case timeout
    }
}

@MainActor
class WebViewPool {
    private var pool: [WKWebView]
    private let semaphore: DispatchSemaphore
    
    private init(size: Int) {
        self.pool = (0..<size).map { _ in
            WKWebView(frame: .zero)
        }
        self.semaphore = DispatchSemaphore(value: size)
    }
    
    func acquire() -> WKWebView? {
        if semaphore.wait(timeout: .now() + 100) == .success {
            return pool.removeFirst()
        } else {
            return nil
        }
    }
    
    func acquireWithRetry(retries: Int = 8, delay: TimeInterval = 0.2) async throws -> WKWebView  {
        for _ in 0..<retries {
            guard let webView = self.acquire() else {
                
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                continue
            }
            return webView
        }
        throw WebViewPool.Error.timeout
    }
    
    func release(_ webView: WKWebView) {
        defer {
            semaphore.signal()
        }
        pool.append(webView)
    }
    
    static let shared: WebViewPool = .init(size: ProcessInfo.processInfo.activeProcessorCount)
}

extension Document {
    
    @MainActor
    internal func print(
        configuration: PDFConfiguration,
        using webView: WKWebView = WKWebView(frame: .zero)
    ) async throws {
        
        let webViewNavigationDelegate = WebViewNavigationDelegate(
            outputURL: self.url,
            configuration: configuration
        )
        
        webView.navigationDelegate = webViewNavigationDelegate
        
        await withCheckedContinuation { continuation in
            let printDelegate = PrintDelegate {
                continuation.resume()
            }
            webViewNavigationDelegate.printDelegate = printDelegate
            webView.loadHTMLString(self.html, baseURL: configuration.baseURL)
        }
        
        
    }
}

class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    private let outputURL: URL
    var printDelegate: PrintDelegate?
    
    private let configuration: PDFConfiguration
    
    init(
        outputURL: URL,
        onFinished: (@Sendable () -> Void)? = nil,
        configuration: PDFConfiguration
    ) {
        self.outputURL = outputURL
        self.configuration = configuration
        self.printDelegate = onFinished.map(PrintDelegate.init)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor [configuration, outputURL, printDelegate] in
            
            webView.frame = .init(origin: .zero, size: configuration.paperSize)
            
            let printOperation = webView.printOperation(with: .pdf(url: outputURL, configuration: configuration))
            
            printOperation.showsPrintPanel = false
            printOperation.showsProgressPanel = false
            printOperation.canSpawnSeparateThread = true
            
            printOperation.runModal(
                for: webView.window ?? NSWindow(),
                delegate: printDelegate,
                didRun: #selector(PrintDelegate.printOperationDidRun(_:success:contextInfo:)),
                contextInfo: nil
            )
        }
    }
}

class PrintDelegate: @unchecked Sendable {
    
    var onFinished: @Sendable () -> Void
    
    init(onFinished: @Sendable @escaping () -> Void) {
        self.onFinished = onFinished
    }
    
    @objc func printOperationDidRun(_ printOperation: NSPrintOperation, success: Bool, contextInfo: UnsafeMutableRawPointer?) {
        Task { @MainActor in
            
            self.onFinished()
        }
    }
}


extension Document {
    /// Prints a single document to a pdf at the given configuration.
    ///
    /// This function is more convenient when you have a directory and just want to title the pdf and save it to the directory.
    ///
    /// ## Example
    /// ```swift
    ///  let html = "<html><body><h1>Hello, World!</h1></body></html>"
    ///  try await html.print(
    ///     title: "helloWorld",
    ///     to: .downloadsDirectory
    ///  )
    /// ```
    ///
    /// - Parameters:
    ///   - title: The title of the pdf
    ///   - directory: The directory at which to print the pdf
    ///   - configuration: The configuration of the pdf document.
    ///
    /// - Throws: `Error` if the function cannot clean up the temporary .html file it creates.
    @MainActor
    public func print(
        configuration: PDFConfiguration
    ) async throws {
        try await [self].print(configuration: configuration)
    }
}

extension String {
    /// Prints a single html string to a pdf at the given directory with the title and margins.
    ///
    /// This function is more convenient when you have a directory and just want to title the pdf and save it to the directory.
    ///
    /// ## Example
    /// ```swift
    ///  let html = "<html><body><h1>Hello, World!</h1></body></html>"
    ///  try await html.print(
    ///     title: "helloWorld",
    ///     to: .downloadsDirectory
    ///  )
    /// ```
    ///
    /// - Parameters:
    ///   - title: The title of the pdf
    ///   - directory: The directory at which to print the pdf
    ///   - configuration: The configuration of the pdf document.
    ///
    /// - Throws: `Error` if the function cannot clean up the temporary .html file it creates.
    public func print(
        title: String,
        to directory: URL,
        configuration: PDFConfiguration
    ) async throws {
        try await Document(url: directory.appendingPathComponent(title, conformingTo: .pdf), html: self)
            .print(configuration: configuration)
    }
}

extension String {
    /// Prints a single html string to a pdf at the given URL, with the given margins.
    ///
    /// ## Example
    /// ```swift
    /// let html = "<html><body><h1>Hello, World!</h1></body></html>"
    /// let url = URL.downloadsDirectory
    ///     .appendingPathComponent("helloWorld", conformingTo: .pdf)
    /// try await html.print(to:url)
    /// ```
    ///
    /// - Parameters:
    ///   - url: The url at which to print the pdf
    ///   - configuration: The configuration of the pdf document.
    ///
    /// - Throws: `Error` if the function cannot clean up the temporary .html file it creates.
    ///
    @MainActor
    public func print(
        to url: URL,
        configuration: PDFConfiguration
    ) async throws {
        try await Document(url: url, html: self).print(configuration: configuration)
    }
}

extension PDFConfiguration {
    public static func a4(margins: EdgeInsets = .a4, baseURL: URL? = nil) -> PDFConfiguration {
        return .init(
            margins: margins,
            paperSize: .paperSize(),
            baseURL: baseURL
        )
    }
}

extension NSEdgeInsets {
    init(
        edgeInsets: EdgeInsets
    ){
        self = .init(
            top: edgeInsets.top,
            left: edgeInsets.left,
            bottom: edgeInsets.bottom,
            right: edgeInsets.right
        )
    }
}

extension CGSize {
    public static func paperSize()-> CGSize {
        CGSize(width: NSPrintInfo.shared.paperSize.width, height: NSPrintInfo.shared.paperSize.height)
    }
}

public extension NSPrintInfo {
    static func pdf(
        url: URL,
        configuration: PDFConfiguration
    ) -> NSPrintInfo {
        
        .pdf(
            url: url,
            paperSize: configuration.paperSize,
            topMargin: configuration.margins.top,
            bottomMargin: configuration.margins.bottom,
            leftMargin: configuration.margins.left,
            rightMargin: configuration.margins.right
        )
    }
    
    static func pdf(
        url: URL,
        paperSize: CGSize = NSPrintInfo.shared.paperSize,
        topMargin: CGFloat = 36,
        bottomMargin: CGFloat = 36,
        leftMargin: CGFloat = 36,
        rightMargin: CGFloat = 36
    ) -> NSPrintInfo {
        NSPrintInfo(
            dictionary: [
                .jobDisposition: NSPrintInfo.JobDisposition.save,
                .jobSavingURL: url,
                .allPages: true,
                .topMargin: topMargin,
                .bottomMargin: bottomMargin,
                .leftMargin: leftMargin,
                .rightMargin: rightMargin,
                .paperSize: paperSize
            ]
        )
    }
}

#endif
