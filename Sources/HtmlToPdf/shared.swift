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
    let rect: CGRect
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
    private let outputURL: URL
    var onFinished: (@Sendable () -> Void)?
    
    private let configuration: PDFConfiguration
    
    init(
        outputURL: URL,
        configuration: PDFConfiguration
    ) {
        self.outputURL = outputURL
        self.configuration = configuration
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor [configuration, outputURL, onFinished] in
            
            webView.frame = configuration.rect
            
            let configuration = WKPDFConfiguration(configuration: configuration)
            
            webView.createPDF(configuration: configuration) { result in
                switch result {
                case .success(let data):
                    do {
                        try FileManager.default.createDirectory(
                            at: outputURL.deletingLastPathComponent(),
                            withIntermediateDirectories: true,
                            attributes: nil
                        )
                        try data.write(to: outputURL)
                        print("PDF saved to \(outputURL.path)")
                    } catch {
                        Swift.print("Failed to save PDF: \(error)")
                    }
                case .failure(let error):
                    Swift.print("Failed to create PDF: \(error)")
                }
                if let onFinished {
                    onFinished()
                }
            }
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
