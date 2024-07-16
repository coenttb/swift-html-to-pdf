//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

#if os(macOS)
import Foundation
import WebKit

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
        configuration: PDFConfiguration = .a4
    ) async throws {
        try await [
            Document(url: directory.appendingPathComponent(title, conformingTo: .pdf), html: self)
        ].print(configuration: configuration)
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
        configuration: PDFConfiguration = .a4
    ) async throws {
        try await [
            self
        ].print(to: url, configuration: configuration)
    }
}
extension String {
    @MainActor
    func print(
        to url: URL,
        configuration: PDFConfiguration = .a4,
        using webView: WKWebView = WKWebView(frame: .zero)
    ) async throws {
        
        let webViewNavigationDelegate = WebViewNavigationDelegate(
            outputURL: url,
            configuration: configuration
        )
        
        webView.navigationDelegate = webViewNavigationDelegate
        webView.loadHTMLString(self, baseURL: nil)
        
        await withCheckedContinuation { continuation in
            webViewNavigationDelegate.printDelegate = .init {
                continuation.resume()
            }
        }
    }
}



extension PDFConfiguration {
    public static func a4(margins: EdgeInsets = .a4) -> PDFConfiguration {
        return .init(paperSize: .paperSize(), margins: margins)
    }
}

extension CGSize {
    static func paperSize()-> CGSize {
        CGSize(width: NSPrintInfo.shared.paperSize.width, height: NSPrintInfo.shared.paperSize.height)
    }
    static func a4() -> CGSize {
        CGSize(width: 595.22, height: 841.85)
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
            
            webView.frame = configuration.printableRect

            let printOperation = webView.printOperation(with: .pdf(url: outputURL))
                       
            printOperation.showsPrintPanel = false
            printOperation.showsProgressPanel = false
            printOperation.canSpawnSeparateThread = true
            
            printOperation.runModal(for: webView.window ?? NSWindow(), delegate: printDelegate, didRun: #selector(PrintDelegate.printOperationDidRun(_:success:contextInfo:)), contextInfo: nil)
            
        }
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

class PrintDelegate: @unchecked Sendable {
    
    var onFinished: @Sendable () -> Void
    
    init(onFinished: @Sendable @escaping () -> Void) {
        self.onFinished = onFinished
    }
    
    @objc func printOperationDidRun(_ printOperation: NSPrintOperation, success: Bool, contextInfo: UnsafeMutableRawPointer?) {
        print("printOperationDidRun.success", success)
        onFinished()
    }
}

#endif
