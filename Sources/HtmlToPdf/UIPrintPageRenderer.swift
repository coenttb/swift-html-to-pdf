//
//  swift-html-to-pdf | iOS.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

#if canImport(UIKit)

import Foundation
import UIKit
import WebKit

extension Document {
    
    /// Prints a ``Document`` to PDF with the given configuration.
    ///
    /// This function is more convenient when you have a directory and just want to title the PDF and save it to the directory.
    ///
    /// ## Example
    /// ```swift
    /// try await Document.init(...)
    ///     .print(configuration: .a4)
    /// ```
    ///
    /// - Parameters:
    ///   - configuration: The configuration of the PDF document.
    ///
    /// - Throws: `Error` if the function cannot write to the document's fileUrl.
    @MainActor
    public func print(
        configuration: PDFConfiguration,
        createDirectories: Bool = true
    ) async throws {
        
        if html.containsImages() {
            try await DocumentWKRenderer(
                document: self,
                configuration: configuration,
                createDirectories: createDirectories
            ).print()
            
        } else {
            try await print(
                configuration: configuration,
                createDirectories: createDirectories,
                printFormatter: UIMarkupTextPrintFormatter(markupText: self.html)
            )
        }
    }
}

extension String {
    
    /// Determines if the HTML string contains any `<img>` tags.
    /// - Returns: A boolean indicating whether the HTML contains images.
    func containsImages() -> Bool {
        let imgRegex = "<img\\s+[^>]*src\\s*=\\s*['\"]([^'\"]*)['\"][^>]*>"
        
        do {
            let regex = try NSRegularExpression(pattern: imgRegex, options: .caseInsensitive)
            let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
            return !matches.isEmpty
            
        } catch {
            Swift.print("Regex error: \(error.localizedDescription)")
            return false
        }
    }
}

extension Document {
    
    /// Internal method to print the document using a custom UIPrintFormatter.
    /// - Parameters:
    ///   - configuration: The PDF configuration for printing.
    ///   - createDirectories: Flag to create directories if they don't exist. Default is `true`.
    ///   - printFormatter: The formatter used for printing the document content.
    @MainActor
    internal func print(
        configuration: PDFConfiguration,
        createDirectories: Bool = true,
        printFormatter: UIPrintFormatter
    ) async throws {
        if createDirectories {
            try FileManager.default.createDirectory(at: self.fileUrl.deletingPathExtension().deletingLastPathComponent(), withIntermediateDirectories: true)
        }

        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)

        let paperRect = CGRect(origin: .zero, size: configuration.paperSize)
        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: configuration.printableRect), forKey: "printableRect")

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSRange(location: 0, length: renderer.numberOfPages))

        let bounds = UIGraphicsGetPDFContextBounds()

        (0..<renderer.numberOfPages).forEach { index in
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: index, in: bounds)
        }

        UIGraphicsEndPDFContext()

        try pdfData.write(to: self.fileUrl)
    }
}

private class DocumentWKRenderer: NSObject, WKNavigationDelegate {
    private var document: Document
    private var configuration: PDFConfiguration
    private var createDirectories: Bool
    
    private var continuation: CheckedContinuation<Void, Error>?
    private var webView: WKWebView?
    private var timeoutTask: Task<Void, Error>?
    
    init(
        document: Document,
        configuration: PDFConfiguration,
        createDirectories: Bool
    ) {
        self.document = document
        self.configuration = configuration
        self.createDirectories = createDirectories
        super.init()
    }
    
    @MainActor
    public func print(timeout: TimeInterval = 30) async throws {
        let webView = try await WebViewPool.shared.acquireWithRetry()
        webView.navigationDelegate = self
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            webView.loadHTMLString(document.html, baseURL: configuration.baseURL)
            
            timeoutTask = Task {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                if self.continuation != nil {
                    throw NSError(domain: "DocumentWKRenderer", code: -1, userInfo: [NSLocalizedDescriptionKey: "WebView loading timed out"])
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task {
            do {
                try await document.print(
                    configuration: configuration,
                    createDirectories: createDirectories,
                    printFormatter: webView.viewPrintFormatter()
                )
                timeoutTask?.cancel()
                continuation?.resume(returning: ())
            } catch {
                continuation?.resume(throwing: error)
            }
            await cleanup(webView: webView)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        Task {
            timeoutTask?.cancel()
            continuation?.resume(throwing: error)
            await cleanup(webView: webView)
        }
    }
    
    @MainActor
    private func cleanup(webView: WKWebView) async {
        webView.navigationDelegate = nil
        await WebViewPool.shared.release(webView)
    }
}

extension PDFConfiguration {
    public static func a4(margins: EdgeInsets) -> PDFConfiguration {
        return .init(
            margins: margins,
            paperSize: .a4()
        )
    }
}

extension CGSize {
    public static func paperSize() -> CGSize {
        CGSize(width: 595.22, height: 841.85)
    }
}

extension UIEdgeInsets {
    init(
        edgeInsets: EdgeInsets
    ) {
        self = .init(
            top: .init(edgeInsets.top),
            left: .init(edgeInsets.left),
            bottom: .init(edgeInsets.bottom),
            right: .init(edgeInsets.right)
        )
    }
}

#endif
