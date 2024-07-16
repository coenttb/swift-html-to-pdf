//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

#if os(iOS)

import Foundation
import WebKit

extension String {
    /// Prints a single html string to a pdf at the given directory with the title and margins.
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
    ///   - margins: The margins of the pdf document, defaulting to a4.
    ///
    /// - Throws: `Error` if the function cannot clean up the temporary .html file it creates.
    ///
    public func print(
        title: String,
        to directory: URL,
        configuration: PDFConfiguration = .a4
    ) async throws {
        try await self.print(
            to: directory.appendingPathComponent(title).appendingPathExtension("pdf"),
            configuration: configuration
        )
    }
}

extension String {
    @MainActor
    public func print(
        to url: URL,
        configuration: PDFConfiguration = .a4,
        using webView: WKWebView = WKWebView(frame: .zero)
    ) async throws {
        let tempHTMLFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("html")
        
        do {
            try self.write(to: tempHTMLFileURL, atomically: true, encoding: .utf8)
        } catch {
            throw error
        }
        
        defer {
            try? FileManager.default.removeItem(at: tempHTMLFileURL)
        }
        
        let request = URLRequest(url: tempHTMLFileURL)
        
        let webViewNavigationDelegate = WebViewNavigationDelegate(
            outputURL: url,
            configuration: configuration
        )
        
        webView.navigationDelegate = webViewNavigationDelegate
        webView.load(request)
        
        await withCheckedContinuation { continuation in
            webViewNavigationDelegate.onFinished = {
                continuation.resume()
            }
        }
    }
}

extension UIEdgeInsets {
    public static let a4: UIEdgeInsets = UIEdgeInsets(
        top: -36,
        left: -36,
        bottom: 36,
        right: 36
    )
}

extension PDFConfiguration {
    public static func a4(margins: UIEdgeInsets = .a4) -> PDFConfiguration {
        
        let pageWidth: CGFloat = 595.22
        let pageHeight: CGFloat = 841.85
        let printableWidth = pageWidth - margins.left - margins.right
        let printableHeight = pageHeight - margins.top - margins.bottom
        
        let rect = CGRect(
            x: margins.left,
            y: margins.top,
            width: printableWidth,
            height: printableHeight
        )
        
        return .init(rect: rect)
    }
}

extension CGRect {
    static let paperSize: CGRect = CGRect(x: 0, y: 0, width: PrintInfo.shared.paperSize.width, height: PrintInfo.shared.paperSize.height)
}

#endif
